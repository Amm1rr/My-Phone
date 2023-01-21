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
	
	Public sql As SQL
	Public AppsList As List			'-- All Installed Apps
	Public NormalAppsList As List	'-- Normal Apps to show
	Public HomeApps As List		'-- Home Screen Apps
	Public ShowToastLog As Boolean = True
	
	Public Pref As Settings
	
	Type App(Name As String, _
			PackageName As String, _
			index As Int, _
			IsHomeApp As Boolean, _
			Icon As Bitmap)
	
	Type Settings(CameraApp As String, _
			 PhoneApp As String, _
			 ClockApp As String, _
			 ShowIcon As Boolean, _
			 ShowKeyboard As Boolean, _
			 AutoRunApp As Boolean, _
			 MyPackage As String, _
			 ShowIconHomeApps As Boolean)

End Sub

Sub Service_Create
	'This is the program entry point.
	'This is a good place to load resources that are not specific to a single activity.
	
	CreateDB
	
	PhoneEvent.InitializeWithPhoneState("PhoneEvent", PhID)
	
	SetupSettings
	SetupAppsList

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
	SetupAppsList
	B4XPages.MainPage.RemoveAsRecently(Package)
	B4XPages.MainPage.RemoveHomeItem(Package)
	B4XPages.MainPage.SaveHomeList
End Sub

Sub PhoneEvent_PackageAdded (Package As String, Intent As Intent)
	B4XPages.MainPage.MyLog("Event: PE_PackageAdded => " & Package)
	ToastMessageShow(B4XPages.MainPage.GetAppNamebyPackage(Package) & " Installed!", True)
	SetupAppsList
	B4XPages.MainPage.AddToRecently("", Package)
End Sub

Private Sub SetupSettings
	Dim tmpResult As String
	Dim CurSettingSql As ResultSet
		CurSettingSql = sql.ExecQuery("SELECT * FROM Settings")
	
	Pref.MyPackage = Application.PackageName '"my.phone"
	
	For i = 0 To CurSettingSql.RowCount - 1
		CurSettingSql.Position = i
		tmpResult = CurSettingSql.GetString("KeySetting")
		
		Select tmpResult:
			Case "CameraApp"
				Pref.CameraApp = CurSettingSql.GetString("Value")
				
			Case "PhoneApp"
				Pref.PhoneApp = CurSettingSql.GetString("Value")
				
			Case "ClockApp"
				Pref.ClockApp = CurSettingSql.GetString("Value")
				
			Case "ShowToastLog"
				ShowToastLog = StrToBool(CurSettingSql.GetInt("Value"))
				
			Case "AutoRunApp"
				Pref.AutoRunApp = StrToBool(CurSettingSql.GetInt("Value"))
				
			Case "ShowKeyboard"
				Pref.ShowKeyboard = StrToBool(CurSettingSql.GetString("Value"))
				
			Case "ShowIconHomeApp"
				Pref.ShowIconHomeApps = StrToBool(CurSettingSql.GetInt("Value"))
				
			Case "ShowIcon"
				Pref.ShowIcon = StrToBool(CurSettingSql.GetInt("Value"))
				
		End Select
	Next
	CurSettingSql.Close
End Sub

Public Sub StrToBool(text As String) As Boolean
	If (text.Length <= 0) Then Return False
	
	If (text.ToLowerCase = "true") Then Return True
	
	Dim tmp As Int
	Try
		tmp = text.As(Int)
	Catch
		tmp = 0
	End Try
	
	If (tmp > 0) Then
		Return True
	Else
		Return False
	End If
	
End Sub

Private Sub SetupAppsList
	
	If Not (AppsList.IsInitialized) Then AppsList.Initialize
	If Not (HomeApps.IsInitialized) Then HomeApps.Initialize
	
'	Dim Count As Int = sql.ExecQuerySingleResult("SELECT count(ID) FROM Apps")

	'// All Apps as Database
	Dim ResApps As ResultSet = sql.ExecQuery("SELECT * FROM AllApps")
	
	'// All Apps as System
	Dim pm As PackageManager
	Dim packages As List
		packages = pm.GetInstalledPackages
	
	If (ResApps.RowCount = packages.Size) Then
		
		'// Config Apps List
		'
		
		ResApps.Close
		
		ResApps = sql.ExecQuery("SELECT * FROM Apps")
		
		Dim sortindex As Int
		Do While ResApps.NextRow
			
			Dim currentapp As App
				currentapp.PackageName = ResApps.GetString("pkgName")
				currentapp.Name = ResApps.GetString("Name")
				sortindex = sortindex + 1
				currentapp.index = sortindex
				currentapp.Icon = GetPackageIcon(currentapp.PackageName)
				
'			AppsList.Add(ResApps.GetString("pkgName"))
			AppsList.Add(currentapp)
			
		Loop
		ResApps.Close
		
		'// Home Apps
		
		Dim ResHome As ResultSet = sql.ExecQuery("SELECT * FROM Home")
		
		For i = 0 To ResHome.RowCount - 1
			ResHome.Position = i
			
			Dim currentHomeapp As App
				currentHomeapp.PackageName = ResHome.GetString("pkgName")
				currentHomeapp.Name = ResHome.GetString("Name")
				sortindex = i + 1
				currentHomeapp.index = sortindex
				currentHomeapp.Icon = GetPackageIcon(currentHomeapp.PackageName)
				
'			HomeApps.Add(ResHome.GetString("pkgName"))
			HomeApps.Add(currentHomeapp)
		Next
		ResHome.Close
		
	Else
		
		For i = 0 To packages.Size - 1
			Dim p As String = packages.Get(i)
			
			'//-- This will test whether the app is a 'regular' app that
			'//-- can be launched and if so you can then show it in your app drawer.
			'//-- If the app has been uninstalled, or if it isn't for normal use,
			'//-- then it will return false.
			If pm.GetApplicationIntent(p).IsInitialized Then
				Dim currentapp As App
					currentapp.Name = pm.GetApplicationLabel(p)
					currentapp.PackageName = p
					sortindex = sortindex + 1
					currentapp.index = sortindex
					currentapp.Icon = GetPackageIcon(p)
					currentapp.IsHomeApp = False
				
				AppsList.Add(currentapp)
			End If
		Next
		
		
		Dim ResHome As ResultSet = sql.ExecQuery("SELECT * FROM Home")
		
		For i = 0 To ResHome.RowCount - 1
			ResHome.Position = i
			
			Dim currentHomeapp As App
				currentHomeapp.PackageName = ResHome.GetString("pkgName")
				currentHomeapp.Name = ResHome.GetString("Name")
				sortindex = i + 1
				currentHomeapp.index = sortindex
'				currentapp.Icon = GetPackageIcon(currentHomeapp.PackageName)
				currentHomeapp.IsHomeApp = True
				
			HomeApps.Add(currentHomeapp)
		Next
		ResHome.Close
	End If
	
End Sub

Public Sub CreateDB
	If Not (File.Exists(File.DirInternal, "MyPhone.db")) Then
		File.Copy(File.DirAssets, "MyPhone.db", File.DirInternal, "MyPhone.db")
	End If
	
	sql.Initialize(File.DirInternal, "MyPhone.db", False)
End Sub

public Sub GetPackageIcon(PackageName As String) As Bitmap
	Try
'		LogColor("GetPackageIcon => " & PackageName, Colors.Yellow)
		
		Dim pm As PackageManager, Data As Object = pm.GetApplicationIcon(PackageName)
		If Data Is BitmapDrawable Then
			Dim Icon As BitmapDrawable = Data
			Return Icon.Bitmap
		Else
			Return GetBmpFromDrawable(Data, 48dip)
		End If
	Catch
		Log(LastException)
		Return Null
	End Try
End Sub

Private Sub GetBmpFromDrawable(Drawable As Object, Size As Int) As Bitmap
	Dim BMP As Bitmap, BG As Canvas, Drect As Rect
	BMP.InitializeMutable(Size,Size)
	Drect.Initialize(0,0,Size,Size)
	BG.Initialize2(BMP)
	BG.DrawDrawable(Drawable,Drect)
	Return BG.Bitmap
End Sub
