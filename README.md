# Hardening windows server 2019

## Standard

[CIS_Windows_Server_2019_Benchmark.pdf](https://github.com/htorresi/Doc_juiced/files/7689051/CIS_Windows_Server_2019_Benchmark.pdf)

## Pre requirements

* Previously installed Group Policy Management in AD.
* Pre-configured GPO package with windows baseline based in CIS benchmark (Microsoft Security Compliance tool kit 1.0).

## Hardening implementation

1. In the first place, enter the `Dashboard Server`. Once there, please click on `Tools`. Then click on `Group Policy Manager`.

![img_gpomana](https://user-images.githubusercontent.com/85255387/145480011-9ebbf84c-f937-407e-8349-f93fb02931b7.png)

2. Once located in the domain where the GPO will be applied, we go to the `Group Policy Objects` section, Please right click on it, and select the option: `New`.

![img_001](https://user-images.githubusercontent.com/85255387/145480065-1fc0e1ad-c41b-4f6f-9c45-de8c77074959.png)

![img_002](https://user-images.githubusercontent.com/85255387/145480090-ab8f5bb8-68ed-40ca-b0f0-7f912657d79c.png)

3. Once the GROUP is created, we right click on the created GPO and select to `import settings`

![img_003](https://user-images.githubusercontent.com/85255387/145480113-0da2f904-ca07-4fb9-ac8d-9f07fda4e224.png)

4. Click `Next`.

![img_004](https://user-images.githubusercontent.com/85255387/145480190-76ebfdeb-448e-478e-9b43-b16cf90170ee.png)

5. We could make a backup of this GPO but in this case it would not be necessary because the GPO is new, click `Next`.

![img_005](https://user-images.githubusercontent.com/85255387/145480177-4be91bb8-ef42-4ee8-80c1-4432506d6604.png)

6. For this hardening application, the Microsoft tool kit for Windows Server 2019 baseline was previously downloaded.
This is the *[Microsoft Tool kit 1.0](https://www.microsoft.com/en-us/download/details.aspx?id=55319)*.

![img_007](https://user-images.githubusercontent.com/85255387/145480810-03136873-335c-45e2-8bfa-a13642b711f6.png)

7. Select browse -> c:downolads -> Windows Server 2019 Security Baseline -> GPOs, click `Next`.

![img_006](https://user-images.githubusercontent.com/85255387/145480880-af35eb47-caec-43e4-9f75-48ab1ed9c467.png)

8. We select the GPO to use in this case `MSFT Windows Server 2019 member server` is used, click `Next`.

![img_08](https://user-images.githubusercontent.com/85255387/145480906-fa73caf3-a766-4d19-ad34-80e2f1df2a69.png)

9. Click `Next`

![img_009](https://user-images.githubusercontent.com/85255387/145480940-c96e5eee-784f-491f-83be-693b9c9c10e6.png)

10. Click `Next`

![img_010](https://user-images.githubusercontent.com/85255387/145480952-136cb70c-ae97-45e6-beb8-25e3f404df7f.png)

11. Click `Finish`

![img_011](https://user-images.githubusercontent.com/85255387/145480976-177aabb7-08f9-431d-b837-6183452b154a.png)

12. Click `Ok`.

![img_012](https://user-images.githubusercontent.com/85255387/145481015-a293386e-275e-4069-b3fc-1b725352093f.png)

13. After configuring the GPOs they are linked in the domain, using right click on computer or user and selecting `Link an existing GPO` and selecting we custom GPO, click `Ok`.

![img_013](https://user-images.githubusercontent.com/85255387/145481030-f0de12b0-b516-436f-b7cd-0b25106b3986.png)

## Exceptions

#### The exceptions are formed by configurations that interfere with the use of the machine to do tests, for example: firewall rules for RDP connections or download utilities etc. and others that must be done locally for the machines that are part of the domain, for example installing programs or features. Therefore, they are not considered for the application of hardening through GPOs in the domain.

| Rule                                                                                                                                              | Severity | Failed |
| ------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------ |
| 2.2.21 (L1) Ensure 'Deny access to this computer from the network' is set to 'Guests, Local account and member of Administrators group' (MS only) | High     | 1      |
| 2.3.1.1 (L1) Ensure 'Accounts: Administrator account status' is set to 'Disabled' (MS only)                                                       | High     | 1      |
| 9.3.2 (L1) Ensure 'Windows Firewall: Public: Inbound connections' is set to 'Block (default)'                                                     | High     | 1      |
| 18.2.1 (L1) Ensure LAPS AdmPwd GPO Extension / CSE is installed (MS only)                                                                         | High     | 1      |
| 18.3.5 (L1) Ensure 'Turn on Windows Defender protection against Potentially Unwanted Applications' is set to 'Enabled'                            | High     | 1      |
| 18.5.4.1 (L1) Set 'NetBIOS node type' to 'P-node' (Ensure NetBT Parameter 'NodeType' is set to '0x2 (2)') (MS Only)                               | High     | 1      |
| 18.5.11.3 (L1) Ensure 'Prohibit use of Internet Connection Sharing on your DNS domain network' is set to 'Enabled'                                | High     | 1      |
| 18.9.44.1 (L1) Ensure 'Block all consumer Microsoft account user authentication' is set to 'Enabled'                                              | High     | 1      |
| 18.9.76.13.1.1 (L1) Ensure 'Configure Attack Surface Reduction rules' is set to 'Enabled'                                                         | High     | 1      |
| 18.9.76.13.1.2 (L1) Ensure 'Configure Attack Surface Reduction rules: Set the state for each ASR rule' is 'configured'                            | High     | 1      |
| 18.9.76.13.3.1 (L1) Ensure 'Prevent users and apps from accessing dangerous websites' is set to 'Enabled: Block'                                  | High     | 1      |
| 18.9.79.1.1 (L1) Ensure 'Prevent users from modifying settings' is set to 'Enabled'                                                               | High     | 1      |
| 18.9.101.1.1 (L1) Ensure 'Manage preview builds' is set to 'Enabled: Disable preview builds'                                                      | High     | 1      |
| 18.9.101.1.2 (L1) Ensure 'Select when Preview Builds and Feature Updates are received' is set to 'Enabled: Semi-Annual Channel, 180 or more days' | High     | 1      |
| 18.9.101.1.3 (L1) Ensure 'Select when Quality Updates are received' is set to 'Enabled: 0 days'                                                   | High     | 1      |
