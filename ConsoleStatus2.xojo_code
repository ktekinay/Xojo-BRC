#tag Class
Protected Class ConsoleStatus2
	#tag Method, Flags = &h21
		Private Sub ClearPrevious()
		  if IsDisabled then
		    return
		  end if
		  
		  If CurrentMessage <> "" Then
		    stdout.WriteLine Chr(13) + CurrentMessage + "... done!" + k80Spaces.Left(15)
		    CurrentMessage = ""
		  End If
		  StdOut.Flush
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(spinnerCharacters As String = kSpinnerAscii)
		  // Comment
		  mSpinnerCharacters = spinnerCharacters.Split("")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Finish()
		  ClearPrevious
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HmsFromSeconds(seconds As Double, displayMilliseconds As Boolean = False) As String
		  dim origSeconds as double = seconds
		  seconds = abs(seconds)
		  
		  Dim hours As Integer = Floor(seconds / kSecondsInHour)
		  seconds = seconds Mod kSecondsInHour
		  
		  Dim minutes As Integer = Floor(seconds / kSecondsInMinute)
		  seconds = seconds Mod kSecondsInMinute
		  
		  Dim parts() As String
		  
		  If hours > 0 Then
		    parts.Append Format(hours, "00")
		  End If
		  
		  parts.Append Format(minutes, "00")
		  
		  if displayMilliseconds then
		    var ms as double = origSeconds - floor(origSeconds)
		    seconds = seconds + ms
		    parts.Append Format(seconds, "00.000")
		  else
		    parts.Append Format(seconds, "00")
		  end if
		  
		  dim result as string = Join(parts, ":")
		  if origSeconds < 0.0 then
		    result = "-" + result
		  end if
		  
		  return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Message(message As String)
		  ClearPrevious
		  CurrentMessage = message
		  
		  stdout.Write CurrentMessage + "... "
		  stdout.Flush
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Percent(currentCount As Integer)
		  if IsDisabled then
		    return
		  end if
		  
		  Dim thisTick As Integer = Ticks
		  
		  If thisTick - LastTick > 12 Then
		    LastTick = thisTick
		    Self.CurrentCount = CurrentCount
		    
		    Dim percent As Integer = 100.0 * (CurrentCount / TotalCount)
		    Dim percentStr As String = StringUtils.PadLeft(Str(percent), 3) + "%"
		    Dim remaining As String
		    
		    Dim sTaken As Double = (Microseconds - StartTime) / 1000.0 / 1000.0
		    
		    If sTaken > 10 Then
		      Dim sPer As Double = sTaken / currentCount
		      Dim perMessage as String = " " + sPer.ToString + " per"
		      
		      Dim sLeft As Double = sPer * (TotalCount - currentCount)
		      Dim leftMessage as String = HmsFromSeconds(sLeft)
		      
		      remaining = " (" + leftMessage + If(ShowTimePerItem, perMessage, "") + ")"
		    End If
		    
		    stdout.Write Chr(13) + CurrentMessage + "... " + percentStr + remaining + k80Spaces.Left(4)
		    stdout.Flush
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PercentMessage(continueTimeFromLast As Boolean = False, message As String, totalCount As Integer)
		  LastTick = -1000
		  
		  If Not continueTimeFromLast Then
		    StartTime = Microseconds
		  End If
		  
		  ClearPrevious
		  
		  Self.TotalCount = TotalCount
		  
		  if IsEnabled then
		    CurrentMessage = message
		    Percent 0
		  else
		    Message message
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Spin()
		  if IsDisabled then
		    return
		  end if
		  
		  Dim thisTick As Integer = Ticks
		  
		  If thisTick - LastTick > 12 Then
		    LastTick = thisTick
		    
		    stdout.Write Chr(13) + CurrentMessage + "... " + mSpinnerCharacters(SpinState)
		    stdout.Flush
		    
		    SpinState = If(SpinState = mSpinnerCharacters.Ubound, 0, SpinState + 1)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SpinMessage(message As String)
		  LastTick = -1000
		  
		  ClearPrevious
		  
		  SpinState = 0
		  
		  if IsEnabled then
		    CurrentMessage = message
		    Spin
		  else
		    Message message
		  end if
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		CurrentCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private CurrentMessage As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return not IsEnabled
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  IsEnabled = not value
			  
			End Set
		#tag EndSetter
		Shared IsDisabled As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		Shared IsEnabled As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private LastTick As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSpinnerCharacters() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ShowTimePerItem As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private SpinState As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h21
		Private StartTime As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		TotalCount As Integer
	#tag EndProperty


	#tag Constant, Name = k80Spaces, Type = String, Dynamic = False, Default = \"                                                                                ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSecondsInHour, Type = Double, Dynamic = False, Default = \"3600", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kSecondsInMinute, Type = Double, Dynamic = False, Default = \"60", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kSpinnerArrows, Type = String, Dynamic = False, Default = \"\xE2\x86\x90\xE2\x86\x96\xE2\x86\x91\xE2\x86\x97\xE2\x86\x92\xE2\x86\x98\xE2\x86\x93\xE2\x86\x99", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSpinnerAscii, Type = String, Dynamic = False, Default = \"\\|/-", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSpinnerAsciiArrows, Type = String, Dynamic = False, Default = \"v<^>", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSpinnerBlocksHorizontal, Type = String, Dynamic = False, Default = \"\xE2\x96\x89\xE2\x96\x8A\xE2\x96\x8B\xE2\x96\x8C\xE2\x96\x8D\xE2\x96\x8E\xE2\x96\x8F\xE2\x96\x8E\xE2\x96\x8D\xE2\x96\x8C\xE2\x96\x8B\xE2\x96\x8A\xE2\x96\x89", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSpinnerBlocksRotating, Type = String, Dynamic = False, Default = \"\xE2\x96\x96\xE2\x96\x98\xE2\x96\x9D\xE2\x96\x97", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSpinnerBlocksVertical, Type = String, Dynamic = False, Default = \"\xE2\x96\x81\xE2\x96\x83\xE2\x96\x84\xE2\x96\x85\xE2\x96\x86\xE2\x96\x87\xE2\x96\x88\xE2\x96\x87\xE2\x96\x86\xE2\x96\x85\xE2\x96\x84\xE2\x96\x83", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSpinnerBrailBlock, Type = String, Dynamic = False, Default = \"\xE2\xA3\xBE\xE2\xA3\xBD\xE2\xA3\xBB\xE2\xA2\xBF\xE2\xA1\xBF\xE2\xA3\x9F\xE2\xA3\xAF\xE2\xA3\xB7", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSpinnerBrailDot, Type = String, Dynamic = False, Default = \"\xE2\xA0\x81\xE2\xA0\x82\xE2\xA0\x84\xE2\xA1\x80\xE2\xA2\x80\xE2\xA0\xA0\xE2\xA0\x90\xE2\xA0\x88", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSpinnerBurstingBalloon, Type = String, Dynamic = False, Default = \".oO@*", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSpinnerClock, Type = String, Dynamic = False, Default = \"\xE2\x97\xB4\xE2\x97\xB7\xE2\x97\xB6\xE2\x97\xB5", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSpinnerLines, Type = String, Dynamic = False, Default = \"\xE2\x94\xA4\xE2\x94\x98\xE2\x94\xB4\xE2\x94\x94\xE2\x94\x9C\xE2\x94\x8C\xE2\x94\xAC\xE2\x94\x90", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSpinnerO, Type = String, Dynamic = False, Default = \"oO", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSpinnerPie, Type = String, Dynamic = False, Default = \"\xE2\x97\x90\xE2\x97\x93\xE2\x97\x91\xE2\x97\x92", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSpinnerPlusX, Type = String, Dynamic = False, Default = \"+X", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSpinnerX, Type = String, Dynamic = False, Default = \"xX", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="CurrentCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TotalCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ShowTimePerItem"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
