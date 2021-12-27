# Windows 10 & 11 Bloatware Removal

The purpose of this script is to remove apps I consider 'bloat', and to clean up the default Windows 10 & 11 Start Menu. 

The majority of the apps that are removed can be re-installed via the Microsoft Store. Check out the table below. 

**Tested On**

Windows 10 Pro/Enterprise: 1803, 1809, 1903, 1909, 2004, 21H1, 21H2\
Windows 11 Pro/Enterprise: 21H2\
Windows Server: 2016, 2019, 2022


**How To Use**
> This script is designed to be run directly after installation of the OS, or during an MDT Task Sequence. 

> After running the script, changes will be visible on the next User Account that is logged on. 

This script does the following:
1) Removes bloatware FOR NEW USERS in a way that allows you to Sysprep the machine if required.
2) Replaces the default start menu layout with something cleaner, and can be customized by you.
3) Disables automatic downloads of ad-content into the Start Menu.
4) Sets Explorer to open to "This PC" instead of "Quick Access".
5) Hides Cortana search box from start menu.
6) Disables OneDrive from installing at launch. 
7) Removes 3D Objects, Desktop, Downloads, Documents, Pictures, Music, Videos from the Explorer start page. 
8) Removes the "Open with 3D Print" on a right click of a JPG,PNG, other pictures formats. 


For general information regarding Windows 10 Default Apps, see the <a href='https://docs.microsoft.com/en-us/windows/application-management/apps-in-windows-10'>Microsoft Documentation.</a> 


|   App Name    | Removal Reasoning    | Where to Download | 
| ------------- |--------------|--------------|
| Bing Weather     | Not required for day-to-day use | https://www.microsoft.com/store/productId/9WZDNCRFJ3Q2|
| Get Help     | Not required for day-to-day use | https://www.microsoft.com/store/productId/9PKDZBMV1H3T |
| Get Started | Not required for day-to-day use | https://www.microsoft.com/store/productId/9WZDNCRDTBJJ |   
| Messaging | Replaced by 'Your Phone' app | https://www.microsoft.com/store/productId/9WZDNCRFJBQ6 |
| 3D Viewer | Not required for day-to-day use | https://www.microsoft.com/store/productId/9NBLGGH42THS |
| Office Hub | If you need Office, you will install real Office | https://www.microsoft.com/store/productId/9WZDNCRD29V9 |
| Solitaire Collection | Not required for day-to-day use | https://www.microsoft.com/store/productId/9WZDNCRFHWD2 |
| Sticky Notes | Not required for day-to-day use | https://www.microsoft.com/store/productId/9NBLGGH4QGHW |
| Mixed Reality Portal | VR Desktop, Not required for day-to-day use | https://www.microsoft.com/store/productId/9NG1H8B3ZC7M |
| 3D Paint | Not required for day-to-day use | https://www.microsoft.com/store/productId/9NBLGGH5FV99 |
| One Note | If you need OneNote, install it | https://www.microsoft.com/store/productId/9WZDNCRFHVJL |
| OneConnect | Old App, not included in latest releases of Windows 10 |  |  
| People | Not required for day-to-day use | https://www.microsoft.com/store/productId/9NBLGGH10PG8 |
| Print 3D | Not required for day-to-day use | https://www.microsoft.com/store/productId/9PBPCH085S3S |
| Skype | Not required for day-to-day use | https://www.microsoft.com/store/productId/9WZDNCRFJ364 |
| Wallet | Not required for day-to-day use | https://www.microsoft.com/store/productId/9NBLGGH52CKV |
| Windows Alarms | Not required for day-to-day use | https://www.microsoft.com/store/productId/9WZDNCRFJ3PR |
| WindowsCommunicationApps | Not required for day-to-day use | https://www.microsoft.com/store/productId/9WZDNCRFHVQM |
| Windows Maps | Not required for day-to-day use | https://www.microsoft.com/store/productId/9WZDNCRDTBVB |
| Xbox | Not required for day-to-day use | https://www.microsoft.com/store/productId/9MV0B5HZVK9Z |
| XboxGameOverlay | Not required for day-to-day use  | Auto Install via Xbox App |
| XboxIdentityProvider | Not required for day-to-day use | Auto Install via Xbox App |
| XboxSpeechtoTextOverlay | Not required for day-to-day use |  |
| Zune Music | Not required for day-to-day use | https://www.microsoft.com/store/productId/9WZDNCRFJ3PT |
| Zune Video | Not required for day-to-day use | https://www.microsoft.com/store/productId/9WZDNCRFJ3P2 |
