// Copyright (c) 2017-2019, Substratum LLC (https://substratum.net) and/or its affiliates. All rights reserved.

import {ComponentFixture, TestBed} from '@angular/core/testing';
import {NodeConfigurationComponent} from './node-configuration.component';
import * as td from 'testdouble';
import {ConfigService} from '../config.service';
import {FormsModule, ReactiveFormsModule} from '@angular/forms';
import {Router} from '@angular/router';
import {BehaviorSubject} from 'rxjs';
import {NodeConfiguration} from '../node-configuration';
import {NodeConfigurationPage} from './node-configuration-page';
import {of} from 'rxjs/internal/observable/of';
import {MainService} from '../main.service';
import {ConfigurationMode} from '../configuration-mode.enum';
import {NodeStatus} from '../node-status.enum';
import {LocalStorageService} from '../local-storage.service';
import {ElectronService} from '../electron.service';
import {LocalServiceKey} from '../local-service-key.enum';

describe('NodeConfigurationComponent', () => {
  let component: NodeConfigurationComponent;
  let fixture: ComponentFixture<NodeConfigurationComponent>;
  let mockConfigService;
  let page: NodeConfigurationPage;
  let mockRouter;
  let mockNodeStatus;
  let mockNavigateByUrl;
  let mockOpenExternal;
  let storedConfig: BehaviorSubject<NodeConfiguration>;
  let mockMainService;
  let mockConfigMode;
  let mockLocalStorageService;
  let stubElectronService;

  beforeEach(() => {
    storedConfig = new BehaviorSubject(new NodeConfiguration());
    mockConfigMode = new BehaviorSubject(ConfigurationMode.Hidden);
    mockNavigateByUrl = td.func('navigateByUrl');
    mockOpenExternal = td.function('openExternal');

    mockNodeStatus = new BehaviorSubject(new NodeConfiguration());
    stubElectronService = {
      shell: {
        openExternal: mockOpenExternal
      },
    };
    mockMainService = {
      save: td.func('save'),
      nodeStatus: mockNodeStatus,
      lookupIp: td.func('lookupIp'),
    };

    mockConfigService = {
      patchValue: td.func('patchValue'),
      load: td.func('load'),
      mode: mockConfigMode,
    };
    spyOn(mockConfigService, 'patchValue');
    mockLocalStorageService = {
      getItem: td.func('getItem'),
      setItem: td.func(),
      removeItem: td.func()
    };
    spyOn(mockLocalStorageService, 'setItem');
    spyOn(mockLocalStorageService, 'removeItem');
    mockRouter = {
      navigateByUrl: mockNavigateByUrl
    };
    TestBed.configureTestingModule({
      declarations: [NodeConfigurationComponent],
      imports: [
        FormsModule,
        ReactiveFormsModule
      ],
      providers: [
        {provide: ElectronService, useValue: stubElectronService},
        {provide: ConfigService, useValue: mockConfigService},
        {provide: MainService, useValue: mockMainService},
        {provide: Router, useValue: mockRouter},
        {provide: LocalStorageService, useValue: mockLocalStorageService}
      ]
    }).compileComponents();
    td.when(mockConfigService.load()).thenReturn(storedConfig.asObservable());
    fixture = TestBed.createComponent(NodeConfigurationComponent);
    page = new NodeConfigurationPage(fixture);
    component = fixture.componentInstance;
  });

  afterEach(() => {
    td.reset();
  });

  describe('LookupIp', () => {
    describe('successful ip address lookup', () => {
      beforeEach(() => {
        storedConfig.next({ip: '192.168.1.1'});
        fixture.detectChanges();
      });

      describe('ip is filled out if it can be looked up', () => {
        it('ip address is filled out', () => {
          expect(page.ipTxt.value).toBe('192.168.1.1');
        });
      });

      describe('wallet address is provided in config', () => {
        beforeEach(() => {
          storedConfig.next({walletAddress: 'earning wallet address'});
          fixture.detectChanges();
        });

        it('earning wallet address is filled out and readonly', () => {
          expect(page.walletAddressTxt.value).toBe('earning wallet address');
          expect(page.walletAddressTxt.readOnly).toBeTruthy();
        });
      });

      describe('blank earning wallet address', () => {
        beforeEach(() => {
          td.when(mockMainService.lookupIp()).thenReturn(of('192.168.1.1'));
          const expectedNodeConfiguration = new NodeConfiguration();
          expectedNodeConfiguration.walletAddress = null;
          td.when(mockConfigService.load()).thenReturn(of(expectedNodeConfiguration));
          fixture = TestBed.createComponent(NodeConfigurationComponent);
          page = new NodeConfigurationPage(fixture);
          component = fixture.componentInstance;
          fixture.detectChanges();
        });

        it('earning wallet address is blank and writable', () => {
          expect(page.walletAddressTxt.value).toBe('');
          expect(page.walletAddressTxt.readOnly).toBeFalsy();
        });
      });
    });

    describe('unsuccessful ip address lookup', () => {
      describe('the ip field', () => {
        it('ip address starts blank', () => {
          expect(page.ipTxt.value).toBe('');
        });
      });
    });
  });

  describe('Wallet section', () => {
    describe('with a filled out form', () => {
      describe('when submitted', () => {
        const expected = {
          ip: '127.0.0.1',
          neighbor: '5sqcWoSuwaJaSnKHZbfKOmkojs0IgDez5IeVsDk9wno:2.2.2.2:1999',
          walletAddress: '0x0123456789012345678901234567890123456789',
          blockchainServiceUrl: 'https://ropsten.infura.io/v3/<YOUR-PROJECT-ID>',
          privateKey: '',
        };

        beforeEach(() => {
          td.when(mockMainService.lookupIp()).thenReturn(of('192.168.1.1'));
          fixture.detectChanges();
          page.setIp('127.0.0.1');
          page.setNeighbor('5sqcWoSuwaJaSnKHZbfKOmkojs0IgDez5IeVsDk9wno:2.2.2.2:1999');
          page.setWalletAddress('0x0123456789012345678901234567890123456789');
          page.setBlockchainServiceUrl('https://ropsten.infura.io/v3/<YOUR-PROJECT-ID>');
          fixture.detectChanges();

          page.saveConfigBtn.click();

          fixture.detectChanges();
        });

        it('persists the values', () => {
          expect(mockConfigService.patchValue).toHaveBeenCalledWith(expected);
        });
      });
    });
  });

  describe('Configuration', () => {
    beforeEach(() => {
      td.when(mockMainService.lookupIp()).thenReturn(of('1.2.3.4'));
      fixture.detectChanges();
    });

    describe('when it already exists and there is no node descriptor in local storage', () => {
      const expected: NodeConfiguration = {
        ip: '127.0.0.1',
        neighbor: 'neighbornodedescriptor',
        walletAddress: 'address',
        privateKey: ''
      };

      beforeEach(() => {
        td.when(mockLocalStorageService.getItem(LocalServiceKey.NeighborNodeDescriptor)).thenReturn(null);
        td.when(mockLocalStorageService.getItem(LocalServiceKey.PersistNeighborPreference)).thenReturn('false');

        storedConfig.next(expected);
      });

      it('is prepopulated with that data', () => {
        expect(page.ipTxt.value).toBe('127.0.0.1');
        expect(page.neighborTxt.value).toBe('neighbornodedescriptor');
        expect(page.walletAddressTxt.value).toBe('address');
        expect(component.persistNeighbor).toBeFalsy();
      });
    });

    describe('when it already exists and a node descriptor is in local storage', () => {
      const expected: NodeConfiguration = {
        ip: '127.0.0.1',
        neighbor: 'neighbornodedescriptor',
        walletAddress: 'address',
        privateKey: ''
      };

      beforeEach(() => {
        td.when(mockLocalStorageService.getItem(LocalServiceKey.PersistNeighborPreference)).thenReturn('true');

        storedConfig.next(expected);
      });

      it('is prepopulated with that data', () => {
        expect(page.ipTxt.value).toBe('127.0.0.1');
        expect(page.neighborTxt.value).toBe('neighbornodedescriptor');
        expect(page.walletAddressTxt.value).toBe('address');
        expect(component.persistNeighbor).toBeTruthy();
      });
    });

    describe('when clicking the node descriptor help icon', () => {
      beforeEach(() => {
        page.nodeDescriptorHelpImg.click();
        fixture.detectChanges();
      });

      it('displays the help message', () => {
        expect(page.nodeDescriptorTooltip).toBeTruthy();
      });

      describe('clicking anywhere', () => {
        beforeEach(() => {
          expect(page.nodeDescriptorTooltip).toBeTruthy();
          page.containerDiv.click();
          fixture.detectChanges();
        });

        it('hides the help message', () => {
          expect(page.nodeDescriptorTooltip).toBeFalsy();
        });
      });
    });

    describe('when clicking the blockchain service URL help icon', () => {
      beforeEach(() => {
        page.blockchainServiceUrlHelpImg.click();
        fixture.detectChanges();
      });

      it('displays the help message', () => {
        expect(page.blockchainServiceUrlTooltip).toBeTruthy();
      });

      describe('clicking anywhere', () => {
        beforeEach(() => {
          expect(page.blockchainServiceUrlTooltip).toBeTruthy();
          page.containerDiv.click();
          fixture.detectChanges();
        });

        it('hides the help message', () => {
          expect(page.blockchainServiceUrlTooltip).toBeFalsy();
        });
      });
    });

    describe('when clicking the blockchain service url help link', () => {
      beforeEach(() => {
        page.blockchainServiceUrlHelpImg.click();
        fixture.detectChanges();

        expect(page.blockchainServiceUrlTooltip).toBeTruthy();

        page.blockchainServiceUrlHelpLink.click();
        fixture.detectChanges();
      });

      it('calls openExternal', () => {
        td.verify(mockOpenExternal('https://github.com/SubstratumNetwork/SubstratumNode/blob/master/node/docs/Blockchain-Service.md'));
      });
    });

    describe('Validation', () => {
      describe('ip bad format', () => {
        beforeEach(() => {
          page.setIp('abc123');
          fixture.detectChanges();
        });

        it('displays an invalid format error', () => {
          expect(page.ipValidationPatternLi).toBeTruthy();
        });
      });

      describe('valid ipv4 address', () => {
        beforeEach(() => {
          page.setIp('192.168.1.1');
          fixture.detectChanges();
        });

        it('does not display an invalid format error', () => {
          expect(page.ipValidationPatternLi).toBeFalsy();
        });
      });

      describe('ip missing', () => {
        beforeEach(() => {
          page.setIp('');
          fixture.detectChanges();
        });

        it('ip validation should be invalid', () => {
          expect(page.ipValidationRequiredLi).toBeTruthy();
        });
      });

      describe('bad node descriptor', () => {
        beforeEach(() => {
          page.setNeighbor('pewpew');
          fixture.detectChanges();
        });

        it('is in error if it is not in node descriptor format', () => {
          expect(page.neighborValidationPatternLi).toBeTruthy();
        });
      });

      describe('valid node descriptor', () => {
        beforeEach(() => {
          page.setNeighbor('wsijSuWax0tMAiwYPr5dgV4iuKDVIm5/l+E9BYJjbSI:255.255.255.255:12345;4321');
          fixture.detectChanges();
        });

        it('is not in error if it is in node descriptor format', () => {
          expect(page.neighborValidationPatternLi).toBeFalsy();
        });
      });

      describe('bad wallet address', () => {
        beforeEach(() => {
          page.setWalletAddress('0xbadaddy');
          fixture.detectChanges();
        });

        it('shows a validation error', () => {
          expect(page.walletValidationPatternLi).toBeTruthy();
        });
      });

      describe('valid wallet address', () => {
        beforeEach(() => {
          page.setWalletAddress('0xdddddddddddddddddddddddddddddddddddddddd');
          fixture.detectChanges();
        });

        it('does not show a validation error', () => {
          expect(page.walletValidationPatternLi).toBeFalsy();
        });
      });

      describe('blockchain service URL', () => {
        beforeEach(() => {
          page.setBlockchainServiceUrl('');
          fixture.detectChanges();
        });

        it('is required', () => {
          expect(page.blockchainServiceUrlRequiredValidation).toBeTruthy();
          expect(page.blockchainServiceUrlRequiredValidation.textContent).toContain('Blockchain Service URL is required.');
        });

        describe('when provided with http and valid', () => {
          beforeEach(() => {
            page.setBlockchainServiceUrl('http://ropsten.infura.io/v3/projectid');
            fixture.detectChanges();
          });

          it('is not in error', () => {
            expect(page.blockchainServiceUrlRequiredValidation).toBeFalsy();
          });
        });

        describe('when provided with https and valid', () => {
          beforeEach(() => {
            page.setBlockchainServiceUrl('https://ropsten.infura.io/v3/projectid');
            fixture.detectChanges();
          });

          it('is not in error', () => {
            expect(page.blockchainServiceUrlRequiredValidation).toBeFalsy();
          });
        });

        describe('when provided and invalid', () => {
          beforeEach(() => {
            page.setBlockchainServiceUrl('htp://invalid.com');
            fixture.detectChanges();
          });

          it('shows the error element', () => {
            expect(page.blockchainServiceUrlPatternValidation).toBeTruthy();
          });

          it('contains the proper error message', () => {
            expect(page.blockchainServiceUrlPatternValidation.textContent)
              .toContain('Blockchain Service URL should start with https:// or http://');
          });
        });
      });

      describe('invalid form', () => {
        beforeEach(() => {
          page.setIp('abc123');
          fixture.detectChanges();
        });

        it('disables the save config button', () => {
          expect(page.saveConfigBtn.disabled).toBeTruthy();
        });
      });

      describe('valid filled out form', () => {
        beforeEach(() => {
          page.setIp('192.168.1.1');
          page.setNeighbor('wsijSuWax0tMAiwYPr5dgV4iuKDVIm5/l+E9BYJjbSI:255.255.255.255:12345;4321');
          page.setWalletAddress('0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
          page.setBlockchainServiceUrl('https://ropsten.infura.io/v3/<YOUR-PROJECT-ID>');
          fixture.detectChanges();
        });

        it('does not disable the save config button', () => {
          expect(page.saveConfigBtn.disabled).toBeFalsy();
        });
      });
    });

    describe('Cancel button', () => {
      let cancelEmitted;
      beforeEach(() => {
        cancelEmitted = false;
        component.cancelled.subscribe(() => {
          cancelEmitted = true;
        });
        page.cancelBtn.click();
      });

      it('emits cancel event when pressed', () => {
        expect(cancelEmitted).toBeTruthy();
      });
    });

    describe('Save Button', () => {
      beforeEach(() => {
        td.when(mockMainService.lookupIp()).thenReturn(of('1.2.3.4'));
        fixture.detectChanges();
      });

      describe('when in configuration mode and the node is running', () => {
        beforeEach(() => {
          component.mode = ConfigurationMode.Configuring;
          component.status = NodeStatus.Serving;
          fixture.detectChanges();
        });

        it('Should say "Stop & Save"', () => {
          expect(page.saveConfigBtn.textContent).toBe('Stop & Save');
        });
      });

      describe('when in configuration mode and the node is off', () => {
        beforeEach(() => {
          component.mode = ConfigurationMode.Configuring;
          component.status = NodeStatus.Off;
          fixture.detectChanges();
        });

        it('Should say "Save"', () => {
          expect(page.saveConfigBtn.textContent).toBe('Save');
        });
      });

      describe('when in pre-serving or consuming', () => {
        beforeEach(() => {
          component.mode = ConfigurationMode.Serving;
          component.status = NodeStatus.Off;
          fixture.detectChanges();
        });

        it('Should say "Start"', () => {
          expect(page.saveConfigBtn.textContent).toBe('Start');
        });
      });

      describe('when clicked', () => {
        describe('with a filled out form', () => {
          const expected = {
            ip: '127.0.0.1',
            neighbor: '5sqcWoSuwaJaSnKHZbfKOmkojs0IgDez5IeVsDk9wno:2.2.2.2:1999',
            walletAddress: '',
            blockchainServiceUrl: 'https://ropsten.infura.io/v3/<YOUR-PROJECT-ID>',
            privateKey: ''
          };
          let savedSignalAsserted = false;

          beforeEach(() => {
            page.setIp('127.0.0.1');
            page.setNeighbor('5sqcWoSuwaJaSnKHZbfKOmkojs0IgDez5IeVsDk9wno:2.2.2.2:1999');
            page.setWalletAddress('');
            page.setBlockchainServiceUrl('https://ropsten.infura.io/v3/<YOUR-PROJECT-ID>');
            component.saved.subscribe(() => {
              expect(mockConfigService.patchValue).toHaveBeenCalledWith(expected);
              savedSignalAsserted = true;
            });
            fixture.detectChanges();

            page.saveConfigBtn.click();

            fixture.detectChanges();
          });

          it('persists the values then emits save event', () => {
            expect(savedSignalAsserted).toBeTruthy();
          });
        });

        describe('saving the neighbor node descriptor', () => {
          describe('when the checkbox is NOT checked', () => {
            beforeEach(() => {
              page.setIp('127.0.0.1');
              page.setNeighbor('5sqcWoSuwaJaSnKHZbfKOmkojs0IgDez5IeVsDk9wno:2.2.2.2:1999');
              page.setWalletAddress('');
              page.setBlockchainServiceUrl('https://ropsten.infura.io/v3/<YOUR-PROJECT-ID>');
              fixture.detectChanges();
              page.saveConfigBtn.click();
              fixture.detectChanges();
            });

            it('removes the node descriptor from local storage', () => {
              expect(mockLocalStorageService.removeItem).toHaveBeenCalledWith(LocalServiceKey.NeighborNodeDescriptor);
            });

            it('saves the checkbox state to local storage', () => {
              expect(mockLocalStorageService.setItem).toHaveBeenCalledWith(LocalServiceKey.PersistNeighborPreference, false);
            });
          });

          describe('when the checkbox is checked', () => {
            beforeEach(() => {
              page.setIp('127.0.0.1');
              page.setNeighbor('5sqcWoSuwaJaSnKHZbfKOmkojs0IgDez5IeVsDk9wno:2.2.2.2:1999');
              page.changeRememberNeighbor(true);
              page.setWalletAddress('');
              page.setBlockchainServiceUrl('https://ropsten.infura.io/v3/<YOUR-PROJECT-ID>');
              fixture.detectChanges();
              page.saveConfigBtn.click();
              fixture.detectChanges();
            });

            it('stores the node descriptor in local storage', () => {
              expect(mockLocalStorageService.setItem).toHaveBeenCalledWith(
                LocalServiceKey.NeighborNodeDescriptor,
                '5sqcWoSuwaJaSnKHZbfKOmkojs0IgDez5IeVsDk9wno:2.2.2.2:1999'
              );
            });

            it('saves the checkbox state to local storage', () => {
              expect(mockLocalStorageService.setItem).toHaveBeenCalledWith(LocalServiceKey.PersistNeighborPreference, true);
            });
          });
        });

        describe('saving the blockchain service url', () => {
          beforeEach(() => {
            page.setIp('127.0.0.1');
            page.setNeighbor('5sqcWoSuwaJaSnKHZbfKOmkojs0IgDez5IeVsDk9wno:2.2.2.2:1999');
            page.setWalletAddress('');
            page.setBlockchainServiceUrl('https://infura.io');
            fixture.detectChanges();
            page.saveConfigBtn.click();
            fixture.detectChanges();
          });

          it('saves the blockchain service url', () => {
            expect(mockLocalStorageService.setItem).toHaveBeenCalledWith(LocalServiceKey.BlockchainServiceUrl, 'https://infura.io');
          });
        });
      });
    });
  });
});
