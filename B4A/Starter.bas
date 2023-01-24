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
	Public LogMode As Boolean = True
	Public LogList As List
	
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
			 ShowIconHomeApp As Boolean)

End Sub

Sub Service_Create
	'This is the program entry point.
	'This is a good place to load resources that are not specific to a single activity.
	
	CreateDB
	
	PhoneEvent.InitializeWithPhoneState("PhoneEvent", PhID)
	LogList.Initialize
	
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
	MyLog("Event: PE_PackageRemoved => " & Package)
	ToastMessageShow(B4XPages.MainPage.GetAppNamebyPackage(Package) & " Removed!", True)
	SetupAppsList
	B4XPages.MainPage.RemoveAsRecently(Package)
	B4XPages.MainPage.RemoveHomeItem(Package)
	B4XPages.MainPage.SaveHomeList
End Sub

Sub PhoneEvent_PackageAdded (Package As String, Intent As Intent)
	MyLog("Event: PE_PackageAdded => " & Package)
	ToastMessageShow(B4XPages.MainPage.GetAppNamebyPackage(Package) & " Installed!", True)
	SetupAppsList
	B4XPages.MainPage.AddToRecently("", Package)
End Sub

Private Sub MyLog (Text As String)
	If (LogMode) Then
'		Dim txtWriter As TextWriter
'		txtWriter.Initialize(File.OpenOutput(File.DirInternalCache, "MyLog.log", True))
'			txtWriter.WriteList(LogList)
'			txtWriter.Close
'		File.WriteString(File.DirInternalCache, "MyLog.log", Text)
		LogList.Add(Text)
		Log(Text)
		If (ShowToastLog) Then ToastMessageShow(Text, False)
	End If
End Sub

Private Sub SetupSettings
	MyLog("Service : => SetupSettings")
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
				ShowToastLog = ValToBool(CurSettingSql.GetString("Value"))
				
			Case "AutoRunApp"
				Pref.AutoRunApp = ValToBool(CurSettingSql.GetString("Value"))
				
			Case "ShowKeyboard"
				Pref.ShowKeyboard = ValToBool(CurSettingSql.GetString("Value"))
				
			Case "ShowIconHomeApp"
				Pref.ShowIconHomeApp = ValToBool(CurSettingSql.GetString("Value"))
				
			Case "ShowIcon"
				Pref.ShowIcon = ValToBool(CurSettingSql.GetString("Value"))
				
		End Select
	Next
	CurSettingSql.Close
	
'	LogColor("SetupSettings: " & Pref, Colors.Red)

End Sub

Public Sub ValToBool(value As Object) As Boolean
	If (value.As(String).Length <= 0) Then Return False
	If (value.As(String).ToLowerCase = "false") Then Return False
	If (value.As(String).ToLowerCase = "true") Then Return True
	
	Dim tmp As Int
	Try
		tmp = value.As(Int)
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
	
	AppsList.Clear
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
		
		Dim i As Int = 0
		Do While ResApps.NextRow
			
			Dim currentapp As App
				currentapp.PackageName = ResApps.GetString("pkgName")
				currentapp.Name = ResApps.GetString("Name")
				currentapp.IsHomeApp = False
				i = i + 1
				currentapp.index = i
				currentapp.Icon = GetPackageIcon(currentapp.PackageName)
				currentapp.IsHomeApp = False
				
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
				currentHomeapp.index = i + 1
				currentHomeapp.Icon = GetPackageIcon(currentHomeapp.PackageName)
				currentHomeapp.IsHomeApp = True
				
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
					currentapp.index = i + 1
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
				currentHomeapp.index = i + 1
				currentHomeapp.Icon = GetPackageIcon(currentHomeapp.PackageName)
				currentHomeapp.IsHomeApp = True
				
			HomeApps.Add(currentHomeapp)
		Next
		ResHome.Close
	End If
	
End Sub

Public Sub CreateDB
	If Not (File.Exists(File.DirInternal, "MyPhone.db")) Then
		File.Copy(File.DirAssets, "MyPhone.db", File.DirInternal, "MyPhone.db")
		LogColor("Database Replaced!", Colors.Red)
	End If
	
	sql.Initialize(File.DirInternal, "MyPhone.db", False)
End Sub

public Sub GetPackageIcon(pkgName As String) As Bitmap
	Try
'		LogColor("GetPackageIcon => " & PackageName, Colors.Yellow)
		
		Dim pm As PackageManager, Data As Object = pm.GetApplicationIcon(pkgName)
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
