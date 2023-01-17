B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=9.85
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	#ExcludeFromLibrary: True
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	
	Dim PhoneEvent As PhoneEvents
	Dim PhID As PhoneId

End Sub

Sub Service_Create
	'This is the program entry point.
	'This is a good place to load resources that are not specific to a single activity.
	
	PhoneEvent.InitializeWithPhoneState("PhoneEvent", PhID)

End Sub

Sub Service_Start (StartingIntent As Intent)
	Service.StopAutomaticForeground 'Starter service can start in the foreground state in some edge cases.
End Sub

Sub Service_TaskRemoved
	'This event will be raised when the user removes the app from the recent apps list.
End Sub

'Return true to allow the OS default exceptions handler to handle the uncaught exception.
Sub Application_Error (Error As Exception, StackTrace As String) As Boolean
	Return True
End Sub

Sub Service_Destroy

End Sub

Sub PhoneEvent_PackageRemoved (Package As String, Intent As Intent)
	B4XPages.MainPage.MyLog("Event: PE_PackageRemoved => " & Package)
	ToastMessageShow(B4XPages.MainPage.GetAppNamebyPackage(Package) & " Removed!", True)
	B4XPages.MainPage.SetupInstalledApps
	B4XPages.MainPage.RemoveAsRecently(Package)
	B4XPages.MainPage.RemoveHomeItem(Package)
	B4XPages.MainPage.SaveHomeList
End Sub

Sub PhoneEvent_PackageAdded (Package As String, Intent As Intent)
	B4XPages.MainPage.MyLog("Event: PE_PackageAdded => " & Package)
	ToastMessageShow(B4XPages.MainPage.GetAppNamebyPackage(Package) & " Installed!", True)
	B4XPages.MainPage.SetupInstalledApps
	B4XPages.MainPage.AddToRecently("", Package)
End Sub
