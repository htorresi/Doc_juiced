# Hardening windows server 2019

## standard

[CIS_Windows_Server_2019_Benchmark.pdf](https://github.com/htorresi/Doc_juiced/files/7689051/CIS_Windows_Server_2019_Benchmark.pdf)

## pre requirements

* previously installed Group Policy Management in AD
* pre-configured GPO package with windows baseline based in CIS benchmark (Microsoft Security Compliance tool kit 1.0)

## hardening implementation

1. In the first place, enter the `Dashboard Server`. Once there, please click on `Tools`. Then click on `Group Policy Manager`.

![img_gpomana](https://user-images.githubusercontent.com/85255387/145480011-9ebbf84c-f937-407e-8349-f93fb02931b7.png)

2. once located in the domain where the GPO will be applied, we go to the `Group Policy Objects` section, Please right click on it, and select the option: `New`.

![img_001](https://user-images.githubusercontent.com/85255387/145480065-1fc0e1ad-c41b-4f6f-9c45-de8c77074959.png)

![img_002](https://user-images.githubusercontent.com/85255387/145480090-ab8f5bb8-68ed-40ca-b0f0-7f912657d79c.png)

3. Once the GROUP is created, we right click on the created GPO and select to `import settings`

![img_003](https://user-images.githubusercontent.com/85255387/145480113-0da2f904-ca07-4fb9-ac8d-9f07fda4e224.png)

4. click `Next`.

![img_004](https://user-images.githubusercontent.com/85255387/145480190-76ebfdeb-448e-478e-9b43-b16cf90170ee.png)

5. We could make a backup of this GPO but in this case it would not be necessary because the GPO is new, click `Next`.

![img_005](https://user-images.githubusercontent.com/85255387/145480177-4be91bb8-ef42-4ee8-80c1-4432506d6604.png)

6. For this hardening application, the Microsoft tool kit for Windows Server 2019 baseline was previously downloaded.
This is the *[Microsoft Tool kit 1.0](https://www.microsoft.com/en-us/download/details.aspx?id=55319)*.

![img_007](https://user-images.githubusercontent.com/85255387/145480810-03136873-335c-45e2-8bfa-a13642b711f6.png)

7. select browse -> c:downolads -> Windows Server 2019 Security Baseline -> GPOs, click `Next`.

![img_006](https://user-images.githubusercontent.com/85255387/145480880-af35eb47-caec-43e4-9f75-48ab1ed9c467.png)

8. We select the GPO to use in this case `MSFT Windows Server 2019 member server` is used, click `Next`.

![img_08](https://user-images.githubusercontent.com/85255387/145480906-fa73caf3-a766-4d19-ad34-80e2f1df2a69.png)

9. click `Next`

![img_009](https://user-images.githubusercontent.com/85255387/145480940-c96e5eee-784f-491f-83be-693b9c9c10e6.png)

10. click `Next`

![img_010](https://user-images.githubusercontent.com/85255387/145480952-136cb70c-ae97-45e6-beb8-25e3f404df7f.png)

11. click `Finish`

![img_011](https://user-images.githubusercontent.com/85255387/145480976-177aabb7-08f9-431d-b837-6183452b154a.png)

12. click `Ok`.

![img_012](https://user-images.githubusercontent.com/85255387/145481015-a293386e-275e-4069-b3fc-1b725352093f.png)

13. After configuring the GPOs they are linked in the domain, using right click on computer or user and selecting `Link an existing GPO` and selecting we custom GPO, click `Ok`.

![img_013](https://user-images.githubusercontent.com/85255387/145481030-f0de12b0-b516-436f-b7cd-0b25106b3986.png)

## Exceptions

#### the exceptions are formed by configurations that interfere with the use of the machine to do tests, for example: firewall rules for RDP connections or download utilities etc. and others that must be done locally for the machines that are part of the domain, for example installing programs or features. Therefore, they are not considered for the application of hardening through GPOs in the domain.

| Rule                                                                                                                                                                | Severity | Failed |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------ |
| 2.3.10.11 (L1) Ensure 'Network access: Restrict clients allowed to make remote calls to SAM' is set to 'Administrators: Remote Access: Allow' (MS only)             | High     | 1      |
| 18.1.2.2 (L1) Ensure 'Allow input personalization' is set to 'Disabled'                                                                                             | High     | 1      |
| 18.2.1 (L1) Ensure LAPS AdmPwd GPO Extension / CSE is installed (MS only)                                                                                           | High     | 1      |
| 18.3.2 (L1) Ensure 'Configure SMB v1 client driver' is set to 'Enabled: Disable driver'                                                                             | High     | 1      |
| 18.3.3 (L1) Ensure 'Configure SMB v1 server' is set to 'Disabled'                                                                                                   | High     | 1      |
| 18.3.5 (L1) Ensure 'Turn on Windows Defender protection against Potentially Unwanted Applications' is set to 'Enabled'                                              | High     | 1      |
| 18.4.4 (L1) Ensure 'MSS: (EnableICMPRedirect) Allow ICMP redirects to override OSPF generated routes' is set to 'Disabled'                                          | High     | 1      |
| 18.4.6 (L1) Ensure 'MSS: (NoNameReleaseOnDemand) Allow the computer to ignore NetBIOS name release requests except from WINS servers' is set to 'Enabled'           | High     | 1      |
| 18.5.4.1 (L1) Set 'NetBIOS node type' to 'P-node' (Ensure NetBT Parameter 'NodeType' is set to '0x2 (2)') (MS Only)                                                 | High     | 1      |
| 18.5.8.1 (L1) Ensure 'Enable insecure guest logons' is set to 'Disabled'                                                                                            | High     | 1      |
| 18.5.11.3 (L1) Ensure 'Prohibit use of Internet Connection Sharing on your DNS domain network' is set to 'Enabled'                                                  | High     | 1      |
| 18.5.14.1 (L1) Ensure 'Hardened UNC Paths' is set to 'Enabled, with "Require Mutual Authentication" and "Require Integrity" set for all NETLOGON and SYSVOL shares' | High     | 1      |
| 18.8.4.1 (L1) Ensure 'Remote host allows delegation of non-exportable credentials' is set to 'Enabled'                                                              | High     | 1      |
| 18.8.21.4 (L1) Ensure 'Continue experiences on this device' is set to 'Disabled'                                                                                    | High     | 1      |
| 18.8.22.1.5 (L1) Ensure 'Turn off Internet download for Web publishing and online ordering wizards' is set to 'Enabled'                                             | High     | 1      |
| 18.8.27.1 (L1) Ensure 'Block user from showing account details on sign-in' is set to 'Enabled'                                                                      | High     | 1      |
| 18.8.27.6 (L1) Ensure 'Turn off picture password sign-in' is set to 'Enabled'                                                                                       | High     | 1      |
| 18.8.33.6.4 (L1) Ensure 'Require a password when a computer wakes (plugged in)' is set to 'Enabled'                                                                 | High     | 1      |
| 18.9.10.1.1 (L1) Ensure 'Configure enhanced anti-spoofing' is set to 'Enabled'                                                                                      | High     | 1      |
| 18.9.13.1 (L1) Ensure 'Turn off Microsoft consumer experiences' is set to 'Enabled'                                                                                 | High     | 1      |
| 18.9.14.1 (L1) Ensure 'Require pin for pairing' is set to 'Enabled'                                                                                                 | High     | 1      |
| 18.9.16.3 (L1) Ensure 'Disable pre-release features or settings' is set to 'Disabled'                                                                               | High     | 1      |
| 18.9.16.4 (L1) Ensure 'Do not show feedback notifications' is set to 'Enabled'                                                                                      | High     | 1      |
| 18.9.16.5 (L1) Ensure 'Toggle user control over Insider builds' is set to 'Disabled'                                                                                | High     | 1      |
| 18.9.44.1 (L1) Ensure 'Block all consumer Microsoft account user authentication' is set to 'Enabled'                                                                | High     | 1      |
| 18.9.52.1 (L1) Ensure 'Prevent the usage of OneDrive for file storage' is set to 'Enabled'                                                                          | High     | 1      |
| 18.9.76.7.1 (L1) Ensure 'Turn on behavior monitoring' is set to 'Enabled'                                                                                           | High     | 1      |
| 18.9.76.13.1.1 (L1) Ensure 'Configure Attack Surface Reduction rules' is set to 'Enabled'                                                                           | High     | 1      |
| 18.9.76.13.1.2 (L1) Ensure 'Configure Attack Surface Reduction rules: Set the state for each ASR rule' is 'configured'                                              | High     | 1      |
| 18.9.76.13.3.1 (L1) Ensure 'Prevent users and apps from accessing dangerous websites' is set to 'Enabled: Block'                                                    | High     | 1      |
| 18.9.79.1.1 (L1) Ensure 'Prevent users from modifying settings' is set to 'Enabled'                                                                                 | High     | 1      |
| 18.9.84.2 (L1) Ensure 'Allow Windows Ink Workspace' is set to 'Enabled: On, but disallow access above lock' OR 'Disabled' but not 'Enabled: On'                     | High     | 1      |
| 18.9.101.1.1 (L1) Ensure 'Manage preview builds' is set to 'Enabled: Disable preview builds'                                                                        | High     | 1      |
| 18.9.101.1.2 (L1) Ensure 'Select when Preview Builds and Feature Updates are received' is set to 'Enabled: Semi-Annual Channel, 180 or more days'                   | High     | 1      |
| 18.9.101.1.3 (L1) Ensure 'Select when Quality Updates are received' is set to 'Enabled: 0 days'                                                                     | High     | 1      |
