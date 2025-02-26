#tag Class
Protected Class CreateThread
Inherits Thread
	#tag Event
		Sub Run()
		  #if not DebugBuild then
		    #pragma BackgroundTasks false
		  #endif
		  #pragma BoundsChecking false
		  #pragma NilObjectChecking false
		  #pragma StackOverflowChecking false
		  
		  const kEOL as integer = 10
		  const kHyphen as integer = 45
		  const kDot as integer = 46
		  const kZero as integer = 48
		  const kSemicolon as integer = 59
		  
		  var sw as new Stopwatch_MTC
		  sw.Start
		  
		  var cities() as string =self.Cities
		  var bs as BinaryStream = self.BS
		  var rows as integer = self.Count
		  
		  var r as new Random
		  
		  var outMB as new MemoryBlock( 1000000 )
		  var outPtr as ptr = outMB
		  
		  var outMBIndex as integer = 0
		  
		  for row as integer = 1 to rows
		    var cityIndex as integer = r.InRange( 0, cities.LastIndex )
		    var city as string = cities( cityIndex )
		    var cityBytes as integer = city.Bytes
		    
		    if ( outMBIndex + cityBytes + 10 ) >= outMB.Size then
		      Write bs, outMB.StringValue( 0, outMBIndex )
		      outMBIndex = 0
		    end if
		    
		    outMB.StringValue( outMBIndex, cityBytes ) = city
		    outMBIndex = outMBIndex + cityBytes
		    
		    outPtr.Byte( outMBIndex ) = kSemicolon
		    outMBIndex = outMBIndex + 1
		    
		    if r.InRange( 0, 4 ) = 0 then
		      outPtr.Byte( outMBIndex ) = kHyphen
		      outMBIndex = outMBIndex + 1
		    end if
		    
		    var temp as integer = r.InRange( 0, 999 )
		    var t1 as integer = temp \ 100
		    var t2 as integer = ( temp \ 10 ) mod 10
		    var t3 as integer = temp mod 10
		    
		    if t1 <> 0 then
		      outPtr.Byte( outMBIndex ) = t1 + kZero
		      outMBIndex = outMBIndex + 1
		    end if
		    
		    outPtr.Byte( outMBIndex ) = t2 + kZero
		    outMBIndex = outMBIndex + 1
		    
		    outPtr.Byte( outMBIndex ) = kDot
		    outMBIndex = outMBIndex + 1
		    
		    outPtr.Byte( outMBIndex ) = t3 + kZero
		    outMBIndex = outMBIndex + 1
		    
		    outPtr.Byte( outMBIndex ) = kEOL
		    outMBIndex = outMBIndex + 1
		  next
		  
		  if outMBIndex <> 0 then
		    Write bs, outMB.StringValue( 0, outMBIndex )
		  end if
		  
		  sw.Stop
		  'Print "Added " + rows.ToString( "#,##0" ) + " rows in " + sw.ElapsedSeconds.ToString( "#,##0.000" ) + " s"
		  
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Constructor(cities() As String, bs As BinaryStream)
		  self.Type = Thread.Types.Preemptive
		  
		  if BSProtector is nil then
		    BSProtector = new CriticalSection
		    BSProtector.Type = self.Type
		  end if
		  
		  self.BS = bs
		  
		  for each city as string in cities
		    self.Cities.Add city
		  next
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Sub Write(bs As BinaryStream, s As String)
		  BSProtector.Enter
		  bs.Write s
		  BSProtector.Leave
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private BS As BinaryStream
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared BSProtector As CriticalSection
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Cities() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Count As Integer
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="Integer"
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
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
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
			Name="Priority"
			Visible=true
			Group="Behavior"
			InitialValue="5"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="StackSize"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="DebugIdentifier"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ThreadID"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ThreadState"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="ThreadStates"
			EditorType="Enum"
			#tag EnumValues
				"0 - Running"
				"1 - Waiting"
				"2 - Paused"
				"3 - Sleeping"
				"4 - NotRunning"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Type"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="Types"
			EditorType="Enum"
			#tag EnumValues
				"0 - Cooperative"
				"1 - Preemptive"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Count"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
