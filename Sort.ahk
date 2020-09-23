; order A: Ascending, D: Descending
SimpleSortArray(array, order = "A") {
	maxIndex := ObjMaxIndex(array)
	partitions := "|" ObjMinIndex(array) "," maxIndex
	Loop {
		this_partition := SubStr(partitions, InStr(partitions, "|", false, 0) + 1)
		comma := InStr(this_partition, ",")
		spos := pivot := SubStr(this_partition, 1, comma - 1)
		epos := SubStr(this_partition, comma + 1)

		if (order = "A") {
			Loop, % epos - spos
				if (array[pivot] > array[A_Index + spos])
					ObjInsert(array, pivot++, ObjRemove(array, A_Index + spos))
		} else {
			Loop, % epos - spos
				if (array[pivot] < array[A_Index + spos])
					ObjInsert(array, pivot++, ObjRemove(array, A_Index + spos))
		}

		partitions := SubStr(partitions, 1, InStr(partitions, "|", false, 0) - 1)

		if (pivot - spos) > 1                    ;if more than one elements
			partitions .= "|" spos "," pivot-1   ;the left partition
		if (epos - pivot) > 1                    ;if more than one elements
			partitions .= "|" pivot + 1 "," epos ;the right partition

	} Until !partitions
}

SortObjectArrayBy(param_collection, param_iteratees := "") {
	l_array := _CloneDeep(param_collection)

	; if called with a function
	if (IsFunc(param_iteratees)) {
		tempArray := []
		for Key, Value in param_collection {
			bigaIndex := param_iteratees.call(param_collection[Key])
			param_collection[Key].bigaIndex := bigaIndex
			tempArray.push(param_collection[Key])
		}

		l_array := SortObjectArrayBy(tempArray, "bigaIndex")
		for Key, Value in l_array
			l_array[Key].Remove("bigaIndex")

		return l_array
	}

	; if called with shorthands
	if (IsObject(param_iteratees)) {
		; sort the collection however many times is requested by the shorthand identity
		for Key, Value in param_iteratees
			l_array := _InternalSort(l_array, Value)
	} else {
		l_array := _InternalSort(l_array, param_iteratees)
	}

	return l_array
}



_InternalSort(param_collection,param_iteratees:="") {
	l_array := _CloneDeep(param_collection)

	if (param_iteratees != "") {
		; sort associative arrays
		for Index, obj in l_array {
			out .= obj[param_iteratees] "+" Index "|" ; "+" allows for sort to work with just the value
			; out will look like:   value+index|value+index|
		}

		lastValue := l_array[Index, param_iteratees]
	} else {
		; sort regular arrays
		for Index, obj in l_array
			out .= obj "+" Index "|"

		lastValue := l_array[l_array.Count()]
	}
	
	if lastValue is number
		sortType := "N"

	StringTrimRight, out, out, 1 ; remove trailing | 
	Sort, out, % "D| " sortType
	arrStorage := []
	loop, parse, out, |
		arrStorage.push(l_array[SubStr(A_LoopField, InStr(A_LoopField, "+") + 1)])

	return arrStorage
}

_CloneDeep(param_array) {
	Objs := {}
	Obj := param_array.Clone()
	Objs[&param_array] := Obj ; Save this new array
	for Key, Value in Obj {
		if (IsObject(Value)) ; if it is a subarray
			Obj[Key] := Objs[&Value] ; if we already know of a refrence to this array
			? Objs[&Value] ; Then point it to the new array
			: _Clone(Value) ; Otherwise, clone this sub-array
	}

	return Obj
}

_Clone(param_value) {
	if (IsObject(param_value))
		return param_value.Clone()
	else
		return param_value
}