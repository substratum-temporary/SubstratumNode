// Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

use crate::sub_lib::cryptde::CryptData;
use crate::sub_lib::cryptde::PublicKey;
use crate::sub_lib::cryptde::{decodex, CryptDE};
use crate::sub_lib::data_version::DataVersion;
use crate::sub_lib::hop::LiveHop;
use crate::sub_lib::hopper::IncipientCoresPackage;
use crate::sub_lib::hopper::{ExpiredCoresPackage, MessageType, NoLookupIncipientCoresPackage};
use crate::sub_lib::route::Route;
use crate::sub_lib::route::RouteError;
use serde_derive::{Deserialize, Serialize};
use std::net::IpAddr;

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct LiveCoresPackage {
    pub version: DataVersion,
    pub route: Route,
    pub payload: CryptData,
}

impl LiveCoresPackage {
    pub fn version() -> DataVersion {
        DataVersion::new(0, 0).expect("Internal Error")
    }

    pub fn new(route: Route, payload: CryptData) -> LiveCoresPackage {
        Self {
            version: Self::version(),
            route,
            payload,
        }
    }

    pub fn to_next_live(
        mut self,
        cryptde: &dyn CryptDE, // must be the CryptDE of the Node to which the top hop is encrypted
    ) -> Result<(LiveHop, LiveCoresPackage), RouteError> {
        let next_hop = self.route.shift(cryptde)?;
        let next_live = LiveCoresPackage::new(self.route, self.payload);
        Ok((next_hop, next_live))
    }

    pub fn from_no_lookup_incipient(
        no_lookup_incipient: NoLookupIncipientCoresPackage,
        cryptde: &dyn CryptDE, // must be the CryptDE of the Node the package is about to leave
    ) -> Result<(LiveCoresPackage, PublicKey), String> {
        let mut route = match Route::single_hop(&no_lookup_incipient.public_key, cryptde) {
            Ok(r) => r,
            Err(e) => return Err(format!("{:?}", e)),
        };
        route
            .shift(cryptde)
            .expect("CryptDE suddenly changed its keying");
        Ok((
            LiveCoresPackage::new(route, no_lookup_incipient.payload),
            no_lookup_incipient.public_key,
        ))
    }

    pub fn from_incipient(
        incipient: IncipientCoresPackage,
        cryptde: &dyn CryptDE, // must be the CryptDE of the Node to which the top hop is encrypted
    ) -> Result<(LiveCoresPackage, LiveHop), String> {
        let mut route = incipient.route.clone();
        let next_hop = match route.shift(cryptde) {
            Ok(h) => h,
            Err(e) => return Err(format!("Could not decrypt next hop: {:?}", e)),
        };
        Ok((LiveCoresPackage::new(route, incipient.payload), next_hop))
    }

    pub fn to_expired(
        self,
        immediate_neighbor_ip: IpAddr,
        cryptde: &dyn CryptDE, // Must be the CryptDE of the Node for which the payload is intended.
    ) -> Result<ExpiredCoresPackage<MessageType>, String> {
        let top_hop = match self.route.next_hop(cryptde) {
            Err(e) => return Err(format!("{:?}", e)),
            Ok(hop) => hop,
        };
        decodex::<MessageType>(cryptde, &self.payload).map(|decoded_payload| {
            ExpiredCoresPackage::new(
                immediate_neighbor_ip,
                top_hop.payer.map(|p| p.wallet),
                self.route,
                decoded_payload,
                self.payload.len(),
            )
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::blockchain::blockchain_interface::contract_address;
    use crate::sub_lib::cryptde::encodex;
    use crate::sub_lib::cryptde::PlainData;
    use crate::sub_lib::cryptde_null::CryptDENull;
    use crate::sub_lib::dispatcher::Component;
    use crate::sub_lib::hopper::IncipientCoresPackage;
    use crate::sub_lib::node_addr::NodeAddr;
    use crate::sub_lib::route::Route;
    use crate::sub_lib::route::RouteSegment;
    use crate::test_utils::{
        cryptde, make_meaningless_message_type, make_meaningless_route, make_paying_wallet,
        DEFAULT_CHAIN_ID,
    };
    use std::str::FromStr;

    #[test]
    fn live_cores_package_can_be_constructed_from_scratch() {
        let payload = CryptData::new(&[5, 6]);
        let cryptde = cryptde();
        let paying_wallet = make_paying_wallet(b"wallet");
        let route = Route::one_way(
            RouteSegment::new(
                vec![&PublicKey::new(&[1, 2]), &PublicKey::new(&[3, 4])],
                Component::Neighborhood,
            ),
            cryptde,
            Some(paying_wallet),
            Some(contract_address(DEFAULT_CHAIN_ID)),
        )
        .unwrap();

        let subject = LiveCoresPackage::new(route.clone(), payload.clone());

        assert_eq!(subject.route, route);
        assert_eq!(subject.payload, payload);
    }

    #[test]
    fn live_cores_package_can_be_produced_from_older_live_cores_package() {
        let destination_key = PublicKey::new(&[3, 4]);
        let destination_cryptde = CryptDENull::from(&destination_key, DEFAULT_CHAIN_ID);
        let relay_key = PublicKey::new(&[1, 2]);
        let relay_cryptde = CryptDENull::from(&relay_key, DEFAULT_CHAIN_ID);
        let cryptde = cryptde();
        let serialized_payload = serde_cbor::ser::to_vec(&make_meaningless_message_type()).unwrap();
        let encrypted_payload = cryptde
            .encode(&destination_key, &PlainData::new(&serialized_payload))
            .unwrap();
        let paying_wallet = make_paying_wallet(b"wallet");
        let route = Route::one_way(
            RouteSegment::new(vec![&relay_key, &destination_key], Component::Neighborhood),
            cryptde,
            Some(paying_wallet.clone()),
            Some(contract_address(DEFAULT_CHAIN_ID)),
        )
        .unwrap();
        let subject = LiveCoresPackage::new(route.clone(), encrypted_payload.clone());

        let (next_hop, next_pkg) = subject.to_next_live(&relay_cryptde).unwrap();

        assert_eq!(
            next_hop,
            LiveHop::new(
                &destination_key,
                Some(
                    paying_wallet
                        .clone()
                        .as_payer(&relay_key, &contract_address(DEFAULT_CHAIN_ID))
                ),
                Component::Hopper,
            )
        );
        assert_eq!(next_pkg.payload, encrypted_payload);
        let mut route = next_pkg.route.clone();
        let public_key = PublicKey::new(&[]);
        assert_eq!(
            route.shift(&destination_cryptde).unwrap(),
            LiveHop::new(
                &public_key,
                Some(paying_wallet.as_payer(&destination_key, &contract_address(DEFAULT_CHAIN_ID))),
                Component::Neighborhood,
            )
        );
        assert_eq!(
            &route.hops[0].as_slice()[..8],
            &[52, 52, 52, 52, 52, 52, 52, 52]
        ); // garbage
    }

    #[test]
    fn to_next_live_complains_about_bad_input() {
        let subject = LiveCoresPackage::new(Route { hops: vec![] }, CryptData::new(&[]));

        let result = subject.to_next_live(cryptde());

        assert_eq!(result, Err(RouteError::EmptyRoute));
    }

    #[test]
    fn live_cores_package_can_be_constructed_from_no_lookup_incipient_cores_package() {
        let cryptde = cryptde();
        let key34 = PublicKey::new(&[3, 4]);
        let node_addr34 = NodeAddr::new(&IpAddr::from_str("3.4.3.4").unwrap(), &vec![1234]);
        let mut route = Route::single_hop(&key34, cryptde).unwrap();
        let payload = make_meaningless_message_type();

        let incipient =
            NoLookupIncipientCoresPackage::new(cryptde, &key34, &node_addr34, payload.clone())
                .unwrap();
        let (subject, next_stop) =
            LiveCoresPackage::from_no_lookup_incipient(incipient, cryptde).unwrap();

        assert_eq!(key34, next_stop);
        route.shift(cryptde).unwrap();
        assert_eq!(route, subject.route);
        assert_eq!(encodex(cryptde, &key34, &payload).unwrap(), subject.payload,);
    }

    #[test]
    fn from_no_lookup_incipient_relays_errors() {
        let cryptde = cryptde();
        let blank_key = PublicKey::new(&[]);
        let node_addr34 = NodeAddr::new(&IpAddr::from_str("3.4.3.4").unwrap(), &vec![1234]);

        let result = NoLookupIncipientCoresPackage::new(
            cryptde,
            &blank_key,
            &node_addr34,
            make_meaningless_message_type(),
        );

        assert_eq!(
            Err(String::from(
                "Could not encrypt payload: \"Encryption error: EmptyKey\""
            )),
            result
        )
    }

    #[test]
    fn live_cores_package_can_be_constructed_from_incipient_cores_package() {
        let cryptde = cryptde();
        let paying_wallet = make_paying_wallet(b"wallet");
        let key12 = cryptde.public_key();
        let key34 = PublicKey::new(&[3, 4]);
        let key56 = PublicKey::new(&[5, 6]);
        let contract_address = contract_address(DEFAULT_CHAIN_ID);
        let mut route = Route::one_way(
            RouteSegment::new(vec![&key12, &key34, &key56], Component::Neighborhood),
            cryptde,
            Some(paying_wallet.clone()),
            Some(contract_address),
        )
        .unwrap();
        let payload = make_meaningless_message_type();

        let incipient =
            IncipientCoresPackage::new(cryptde, route.clone(), payload.clone(), &key56).unwrap();
        let (subject, next_stop) = LiveCoresPackage::from_incipient(incipient, cryptde).unwrap();

        assert_eq!(
            LiveHop {
                public_key: key34.clone(),
                payer: Some(paying_wallet.as_payer(&key12, &contract_address)),
                component: Component::Hopper
            },
            next_stop
        );
        route.shift(cryptde).unwrap();

        assert_eq!(route, subject.route);
        assert_eq!(encodex(cryptde, &key56, &payload).unwrap(), subject.payload,);
    }

    #[test]
    fn from_incipient_complains_about_problems_decrypting_next_hop() {
        let cryptde = cryptde();
        let incipient = IncipientCoresPackage::new(
            cryptde,
            Route { hops: vec![] },
            make_meaningless_message_type(),
            &PublicKey::new(&[3, 4]),
        )
        .unwrap();
        let result = LiveCoresPackage::from_incipient(incipient, cryptde);

        assert_eq!(
            result,
            Err(String::from("Could not decrypt next hop: EmptyRoute"))
        );
    }

    #[test]
    fn expired_cores_package_can_be_constructed_from_live_cores_package() {
        let immediate_neighbor_ip = IpAddr::from_str("1.2.3.4").unwrap();
        let payload = make_meaningless_message_type();
        let first_stop_key = PublicKey::new(&[3, 4]);
        let first_stop_cryptde = CryptDENull::from(&first_stop_key, DEFAULT_CHAIN_ID);
        let relay_key = PublicKey::new(&[1, 2]);
        let relay_cryptde = CryptDENull::from(&relay_key, DEFAULT_CHAIN_ID);
        let second_stop_key = PublicKey::new(&[5, 6]);
        let second_stop_cryptde = CryptDENull::from(&second_stop_key, DEFAULT_CHAIN_ID);
        let cryptde = cryptde();
        let encrypted_payload = encodex(cryptde, &first_stop_key, &payload).unwrap();
        let paying_wallet = make_paying_wallet(b"wallet");
        let contract_address = contract_address(DEFAULT_CHAIN_ID);
        let mut route = Route::round_trip(
            RouteSegment::new(vec![&relay_key, &first_stop_key], Component::Neighborhood),
            RouteSegment::new(
                vec![&first_stop_key, &relay_key, &second_stop_key],
                Component::ProxyServer,
            ),
            cryptde,
            Some(paying_wallet.clone()),
            1234,
            Some(contract_address),
        )
        .unwrap();
        route.shift(&relay_cryptde).unwrap();
        let subject = LiveCoresPackage::new(route.clone(), encrypted_payload.clone());

        let result = subject
            .to_expired(immediate_neighbor_ip, &first_stop_cryptde)
            .unwrap();

        assert_eq!(result.immediate_neighbor_ip, immediate_neighbor_ip);
        assert_eq!(
            result.paying_wallet,
            Some(paying_wallet.as_address_wallet())
        );
        assert_eq!(result.payload, payload);
        let mut route = result.remaining_route.clone();
        assert_eq!(
            route.shift(&first_stop_cryptde).unwrap(),
            LiveHop::new(
                &relay_key,
                Some(
                    paying_wallet
                        .clone()
                        .as_payer(&first_stop_key, &contract_address)
                ),
                Component::Neighborhood,
            ),
        );
        let empty_public_key = PublicKey::new(&[]);
        assert_eq!(
            route.shift(&relay_cryptde).unwrap(),
            LiveHop::new(
                &second_stop_key,
                Some(
                    paying_wallet
                        .clone()
                        .as_payer(&relay_key, &contract_address)
                ),
                Component::Hopper,
            )
        );
        assert_eq!(
            route.shift(&second_stop_cryptde).unwrap(),
            LiveHop::new(
                &empty_public_key,
                Some(
                    paying_wallet
                        .clone()
                        .as_payer(&second_stop_key, &contract_address)
                ),
                Component::ProxyServer,
            )
        );
        assert_eq!(
            route.hops[0],
            crate::test_utils::encrypt_return_route_id(1234, cryptde),
        );
        route.hops.remove(0);
        assert_eq!(
            &route.hops[0].as_slice()[..8],
            &[52, 52, 52, 52, 52, 52, 52, 52]
        ); // garbage
    }

    #[test]
    fn to_expired_complains_about_bad_route() {
        let subject = LiveCoresPackage::new(
            Route { hops: vec![] },
            CryptData::new(cryptde().private_key().as_slice()),
        );

        let result = subject.to_expired(IpAddr::from_str("1.2.3.4").unwrap(), cryptde());

        assert_eq!(result, Err(format!("{:?}", RouteError::EmptyRoute)));
    }

    #[test]
    fn live_cores_package_serialization_deserialization() {
        let original =
            LiveCoresPackage::new(make_meaningless_route(), CryptData::new(&[1, 2, 3, 4]));

        let serialized = serde_cbor::ser::to_vec(&original).unwrap();

        let deserialized = serde_cbor::de::from_slice::<LiveCoresPackage>(&serialized[..]).unwrap();

        assert_eq!(deserialized, original);
    }
}
