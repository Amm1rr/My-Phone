B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=12.15
@EndOfDesignText@
Sub Class_Globals
	Private Root As B4XView 'ignore
	Private xui As XUI 'ignore
	
	Public ListLog As List
	Private btnLogClose As Button
End Sub

'You can add more parameters here.
Public Sub Initialize As Object
	Return Me
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	'load the layout to Root
	Root.LoadLayout("Log")
	
'	Dim clvLog As CustomListView
'	For Each item In B4XPages.MainPage.LogList
'		clvLog.AddTextItem(item.As(String), item.As(String))
'	Next
	
End Sub

Private Sub B4Xpage_Appear
'	Dim clvLog As CustomListView
'	For Each item In B4XPages.MainPage.LogList
'		clvLog.AddTextItem(item.As(String), item.As(String))
'	Next
End Sub


'You can see the list of page related events in the B4XPagesManager object. The event name is B4XPage.


Private Sub btnLogClose_Click
	Dim MainWin As B4XMainPage
	If Not (MainWin.IsInitialized) Then MainWin.Initialize
	B4XPages.AddPage("MainWin", MainWin)
	B4XPages.ShowPageAndRemovePreviousPages("MainWin")
End Sub
