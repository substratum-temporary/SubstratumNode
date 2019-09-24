# Distributing Release Artifacts
## Overview

Our current configuration of Azure Pipelines involves a multi-stage build pipeline and a
release pipeline. The multi-stage pipeline consists of two stages; Testing and Release.

To produce release artifacts, you can re-trigger a successful build by modifying the
``BUILD_RELEASE_ARTIFACTS`` pipeline variable value to equal ``true``. This will cause
 the build to skip to the Release stage and produce an artifact which you can then pass
 in to the release pipeline.

Then when you're ready to distribute the release artifacts from Azure. You can follow the steps
below:

1. Verify the build pipeline has built the artifacts for the release target.
2. Go to Releases, select the release pipeline and edit the value for ``TAG_NAME`` under
 Variables to match the target release version (for consistency this value should match the
 release tag in the repository e.g. ``v1.0.0-rc3``).
3. Go to Create Release.
4. Under Artifacts, select the build artifact for the release.
5. Click Create.

### Windows

We use AzureSignTool for signing our Windows release binaries. This requires access to
Azure Key Vault where the code signing certificate is stored.

#### Guide to Setup AzureSignTool with Azure Key Vault

These steps assume you already have an account with Azure Key Vault and that you are
signed into the Azure portal.

1. Register your application.
    1. Give it a name (this will be used later as part of the sign-in URL).
    2. Ignore the Redirect URL as it's not needed.
    3. Go to Certificates and secrets for the app and create a client secret.
2. Create your Key Vault.
    1. Add Role assignment under Access control (IAM),
        1. Type the name of the application into the *select* input box.
        2. choose Reader as the Role and then Save.
    2. Add Access Policy under Access policies and add your application.
        1. Key Permissions - Check Get, List, Verify, and Sign
        2. Secret Permissions - Check Get and List
        3. Certificate Permissions - Check Get and List
    3. Go to Certificates and choose Generate/Import to add your certificate.
        1. If importing an existing PFX, then it's recommended that you convert it to
        PEM because otherwise you will likely encounter an error. 
        You can use the openssl command to do this, but depending on which parameters
        you provide it, you may have to manually delete extra lines. Because there should
        be nothing before lines starting with ``-----BEGIN`` and nothing after lines
        starting with ``-----END``.
        
Finally, in order to sign-in with AzureSignTool you will need the following credentials that
were previously setup from the steps above:
* Azure key vault client URL
* Azure key vault client ID (Application ID)
* Azure key vault secret (Application secret)
* Azure key vault name of the certificate

Here's an example:
````
AzureSignTool sign [YOUR_FILE_PATH]
    -kvu https://[YOUR_VAULT_NAME].vault.azure.net
    -kvi [YOUR_CLIENT_ID]
    -kvs [YOUR_CLIENT_SECRET]
    -kvc [YOUR_CERTIFICATE_NAME]
    -tr http://timestamp.digicert.com
    -v
````

For more information about accessing resources from Azure Key Vault, please see this
[document](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal#create-an-azure-active-directory-application).

