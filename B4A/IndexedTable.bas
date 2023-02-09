B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=5.5
@EndOfDesignText@
'Class module
#Event: ItemClick (Position As Int, Value As Object)
Sub Class_Globals
	Public 	tv 						As List
	Private pnlIndex 				As Panel
	Private mTarget 				As Object
	Private mEventName 				As String
	Private hoverLabel 				As Label
	Private const pnlIndexWidth 	As Float = 40dip
	Private CharsMap 				As Map
End Sub

Public Sub Initialize (vCallback As Object, vEventName As String)
	Starter.LogShowToast = False
	Starter.MyLog("****** Event: IndexedTable => " & vEventName)
	mTarget = vCallback
	mEventName = vEventName
	tv.Initialize
	pnlIndex.Initialize("pnlIndex")
	hoverLabel.Initialize("")
	Dim cd As ColorDrawable
		cd.Initialize2(Colors.White, 2dip, 2dip, Colors.Black)
	hoverLabel.Background = cd
	hoverLabel.Visible = False
	hoverLabel.Gravity = Gravity.CENTER
	hoverLabel.TextSize = 17
End Sub

Public Sub DesignerCreateView (base As Panel, lbl As Label, props As Map)
	
End Sub

Public Sub LoadAlphabetlist (base As Panel, Alphalist As Map)
	
'	Starter.LogShowToast = False
'	Starter.MyLog("IndexedTable: LoadAlphabetlist")
	
	pnlIndex.RemoveView
	hoverLabel.RemoveView
	
	base.AddView(hoverLabel, base.Width - 100dip, 0, 40dip, 40dip)
	base.AddView(pnlIndex, base.Width - pnlIndexWidth, 0, pnlIndexWidth, base.Height)
	Dim lblHeight As Float = (pnlIndex.Height - 2dip) / 26
	
	Dim i As Int = 0
	For Each alpha As String In Alphalist.Keys
		Dim lbl As Label
			lbl.Initialize("lbl")
			lbl.Text = Alphalist.GetKeyAt(i)
			lbl.Tag = Alphalist.Get(alpha)
			lbl.TextColor = Colors.LightGray
			lbl.Gravity = Gravity.CENTER
		pnlIndex.AddView(lbl, 0, 2dip + i * lblHeight, pnlIndexWidth, 20dip)
'		LogColor(Alphalist.GetKeyAt(i) & " : " & Alphalist.Get(alpha), Colors.Blue)
		i = i + 1
	Next
	base.Color = Colors.Transparent
End Sub

Private Sub pnlIndex_Touch(Action As Int, X As Float, Y As Float)
	
'	Starter.LogShowToast = False
'	Starter.MyLog("****** Event: IndexedTable: pnlIndex_Touch => Action: " & Action)
	
	Dim item As Int = Y / pnlIndex.Height * pnlIndex.NumberOfViews
		item = Min(item, pnlIndex.NumberOfViews - 1)
	
	If (item < 0) Then
		hoverLabel.Visible = False
		Return
	End If
	
	Dim lbl As Label = pnlIndex.GetView(item)
	If Action = pnlIndex.ACTION_UP Then
		hoverLabel.Visible = False
'		LogColor(lbl.Tag, Colors.Red)
		B4XPages.MainPage.clvApps.ScrollToItem(lbl.Tag)
	Else
		hoverLabel.Visible = True
		hoverLabel.Top = lbl.Top - 15dip
		hoverLabel.Text = lbl.Text
	End If
End Sub

Private Sub BuildIndex
	CharsMap.Initialize
	Dim lastAddedChar As String
	For index = 0 To B4XPages.MainPage.clvApps.Size - 1
		Dim raw As String = B4XPages.MainPage.clvApps.GetValue(index)
		Dim firstLetter As String = raw.CharAt(0).As(String).ToUpperCase
		If firstLetter <> lastAddedChar Then
			lastAddedChar = firstLetter
			CharsMap.Put(lastAddedChar, index)
		End If
	Next
End Sub
