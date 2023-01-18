B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=12.15
@EndOfDesignText@
'
'	How to Use, Example:
'
'		Dim c As RequestDrawOverPermission 'this is the name of the class
'		c.Initialize
'		Wait For (c.GetPermission) Complete (Success As Boolean)
'		Log("Permission: " & Success)
'

Sub Class_Globals
	Private ion As Object
	Private phone As Phone
End Sub

Public Sub Initialize
End Sub

Public Sub GetPermission As ResumableSub
	If phone.SdkVersion >= 23 Then
		Dim settings As JavaObject
		settings.InitializeStatic("android.provider.Settings")
		Dim ctxt As JavaObject
		ctxt.InitializeContext
		If settings.RunMethod("canDrawOverlays", Array(ctxt)) = True Then
			Return True
		End If
		Dim i As Intent
		i.Initialize("android.settings.action.MANAGE_OVERLAY_PERMISSION", "package:" & Application.PackageName)
		StartActivityForResult(i)
		Wait For ion_Event (MethodName As String, Args() As Object)
		Return settings.RunMethod("canDrawOverlays", Array(ctxt))
	Else
		Return True
	End If
End Sub

Private Sub StartActivityForResult(i As Intent)
	Dim jo As JavaObject = GetBA
	ion = jo.CreateEvent("anywheresoftware.b4a.IOnActivityResult", "ion", Null)
	jo.RunMethod("startActivityForResult", Array As Object(ion, i))
End Sub

Private Sub GetBA As Object
	Dim jo As JavaObject = Me
	Return jo.RunMethod("getBA", Null)
End Sub
