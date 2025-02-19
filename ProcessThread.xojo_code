#tag Class
Protected Class ProcessThread
Inherits Thread
	#tag Event
		Sub Run()
		  #if not DebugBuild then
		    #pragma BackgroundTasks false
		  #endif
		  #pragma BoundsChecking false
		  #pragma NilObjectChecking false
		  #pragma StackOverflowChecking false
		  
		  //
		  // Fowler-Noll-Vo hash
		  // https://en.wikipedia.org/wiki/Fowler-Noll-Vo_hash_function
		  //
		  const kFNVOffsetBasis as UInt64 = &hcbf29ce484222325
		  const kFNVPrime as UInt64 = &h100000001b3
		  
		  const kSemiColonByte as integer = 59
		  const kHyphenByte as integer = 45
		  const kEOLByte as integer = 10
		  const kZeroByte as integer = 48
		  const kDotByte as integer = 46
		  
		  //
		  // Set up the map
		  //
		  // (Some prime numbers: 1009, 2003, 3001, 4001, 5003, 6007, 7001, 8009, 9001, 10007)
		  //
		  const kMapSlots as UInt64 = 2003
		  const kMapNumericFields as UInt64 = 5
		  const kMapNameFieldSize as UInt64 = 64
		  const kMapRecordSize as UInt64 = kMapNumericFields * 8 + kMapNameFieldSize
		  const kMapSize as UInt64 = kMapSlots * kMapRecordSize
		  
		  const kMapHashOffset as integer = 0
		  const kMapNameOffset as integer = 8
		  const kMapCountOffset as integer = kMapNameOffset + kMapNameFieldSize
		  const kMapSumOffset as integer = kMapCountOffset + 8
		  const kMapMinOffset as integer = kMapSumOffset + 8
		  const kMapMaxOffset as integer = kMapMinOffset + 8
		  
		  const kZero as UInt64 = 0
		  
		  var mapMB as new MemoryBlock( kMapSize )
		  var mapPtr as ptr = mapMB
		  
		  var mapByteIndex as UInt64
		  
		  var rowCount as integer
		  var indexes() as UInt64
		  
		  do
		    var data as string = PopQueue
		    
		    if data = "" then
		      if IsFinished then
		        exit
		      else
		        continue
		      end if
		    end if
		    
		    var dataMB as MemoryBlock = data
		    dataMB.Size = dataMB.Size + 1
		    
		    var p as ptr = dataMB
		    p.Byte( dataMB.Size - 1 ) = kEOLByte
		    
		    var inName as boolean = true
		    var nameStartByte as integer = 0
		    var nameEndByte as integer
		    
		    var temp as integer
		    
		    var byteIndex as integer
		    var mult as integer
		    
		    var hash as UInt64 = kFNVOffsetBasis
		    var b as byte
		    
		    do
		      byteIndex = byteIndex + 1
		      if byteIndex = dataMB.Size then
		        exit
		      end if
		      
		      b = p.Byte( byteIndex )
		      
		      if inName then
		        if b = kSemiColonByte then
		          inName = false
		          nameEndByte = byteIndex
		          
		          if p.Byte( byteIndex + 1 ) = kHyphenByte then
		            mult = -1
		            byteIndex = byteIndex + 1
		          else
		            mult = 1
		          end if
		          
		        else
		          hash = ( hash * kFNVPrime ) xor b
		        end if
		        
		      else // not inName
		        select case b
		        case kEOLByte
		          rowCount = rowCount + 1
		          temp = temp * mult
		          
		          mapByteIndex = ( hash mod kMapSlots ) * kMapRecordSize
		          
		          do
		            mapByteIndex = mapByteIndex mod kMapSize
		            
		            select case mapPtr.UInt64( mapByteIndex + kMapHashOffset )
		            case hash
		              mapPtr.Int64( mapByteIndex + kMapCountOffset ) = mapPtr.Int64( mapByteIndex + kMapCountOffset ) + 1
		              mapPtr.Int64( mapByteIndex + kMapSumOffset ) = mapPtr.Int64( mapByteIndex + kMapSumOffset ) + temp
		              
		              if temp < mapPtr.Int64( mapByteIndex + kMapMinOffset ) then
		                mapPtr.Int64( mapByteIndex + kMapMinOffset ) = temp
		              end if
		              
		              if temp > mapPtr.Int64( mapByteIndex + kMapMaxOffset ) then
		                mapPtr.Int64( mapByteIndex + kMapMaxOffset ) = temp
		              end if
		              
		              exit
		              
		            case kZero
		              mapPtr.UInt64( mapByteIndex + kMapHashOffset ) = hash
		              mapMB.CopyBytes dataMB, nameStartByte, nameEndByte - nameStartByte, mapByteIndex + kMapNameOffset
		              mapPtr.Int64( mapByteIndex + kMapCountOffset ) = 1
		              mapPtr.Int64( mapByteIndex + kMapSumOffset ) = temp
		              mapPtr.Int64( mapByteIndex + kMapMinOffset ) = temp
		              mapPtr.Int64( mapByteIndex + kMapMaxOffset ) = temp
		              
		              indexes.Add mapByteIndex
		              
		              exit
		              
		            case else
		              mapByteIndex = mapByteIndex + kMapRecordSize
		              
		            end select
		          loop
		          
		          hash = kFNVOffsetBasis
		          temp = 0
		          nameStartByte = byteIndex + 1
		          inName = true
		          
		        case kDotByte
		          
		        case else
		          temp = ( temp * 10 ) + ( b - kZeroByte )
		          
		        end select
		      end if
		    loop
		  loop
		  
		  var dict as new Dictionary
		  
		  for each index as integer in indexes
		    var rec as new Station
		    
		    rec.Name = mapMB.CString( index + kMapNameOffset )
		    rec.Name = rec.Name.DefineEncoding( Encodings.UTF8 )
		    rec.Count = mapPtr.Int64( index + kMapCountOffset )
		    rec.Sum = mapPtr.Int64( index + kMapSumOffset )
		    rec.MinTemp = mapPtr.Int64( index + kMapMinOffset )
		    rec.MaxTemp = mapPtr.Int64( index + kMapMaxOffset )
		    
		    dict.Value( rec.Name ) = rec
		  next
		  
		  self.Result = dict
		  self.RowCount = rowCount
		  
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Shared Sub AddToQueue(s As String)
		  static maxCount as integer = System.CoreCount * 2
		  
		  var waitCount as integer
		  var count as integer
		  
		  do
		    QueueProtector.Enter
		    count = Queue.Count
		    QueueProtector.Leave
		    
		    if count < maxCount then
		      exit
		    else
		      waitCount = waitCount + 1
		    end if
		  loop
		  
		  QueueProtector.Enter
		  Queue.Add s
		  QueueProtector.Leave
		  
		  'if count < System.CoreCount then
		  'System.DebugLog "count: " + count.ToString( "#,##0" )
		  'end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  self.Type = Thread.Types.Preemptive
		  
		  if QueueProtector is nil then
		    QueueProtector = new CriticalSection
		    QueueProtector.Type = self.Type
		    
		    IsFinishedProtector = new CriticalSection
		    IsFinishedProtector.Type = self.Type
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function PopQueue() As String
		  var result as string
		  
		  QueueProtector.Enter
		  if Queue.Count <> 0 then
		    result = Queue.Pop
		  end if
		  QueueProtector.Leave
		  
		  return result
		  
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  IsFinishedProtector.Enter
			  var result as boolean = mIsFinished
			  IsFinishedProtector.Leave
			  
			  return result
			  
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  IsFinishedProtector.Enter
			  mIsFinished = value
			  IsFinishedProtector.Leave
			End Set
		#tag EndSetter
		Shared IsFinished As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private Shared IsFinishedProtector As CriticalSection
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mIsFinished As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared Queue() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared QueueProtector As CriticalSection
	#tag EndProperty

	#tag Property, Flags = &h0
		Result As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		RowCount As Integer
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
			Name="RowCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
