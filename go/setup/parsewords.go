package main

import "github.com/siongui/pali/go/lib"
import "os"
import "encoding/csv"
import "io"
import "strings"

var cs2t = lib.Zhs2zhtConverter()
var dicIndex = lib.GetDicIndex()

func processWord(record []string) {
	// number of the word, useless
	num := record[0]

	// id of the book which the word belongs to
	bookId := record[2]

	// word (The first character of the cell may be upper-case)
	// Google search: golang lowercase
	word := strings.ToLower(record[4])

	// explanation of the pali word in one dictionary
	explanation := record[6]

	println(num + " " + word)
	// Google search: golang check if file exists
	path := lib.GetWordPath(word)
	if _, err := os.Stat(path); err == nil {
		// append new data to existing json file
		wi := lib.GetWordInfo(word)
		if dicIndex[bookId].Lang == "zh" {
			// convert simplified chinese to traditional chinese
			wi[bookId] = cs2t.Convert(explanation)
		} else {
			wi[bookId] = explanation
		}
		lib.SaveJsonFile(wi, path)
	} else {
		// create new json file
		wi := lib.WordInfo{}
		if dicIndex[bookId].Lang == "zh" {
			// convert simplified chinese to traditional chinese
			wi[bookId] = cs2t.Convert(explanation)
		} else {
			wi[bookId] = explanation
		}
		lib.SaveJsonFile(wi, path)
	}
}

func processWordsCSV(csvPath string) {
	// open csv file
	fcsv, err := os.Open(csvPath)
	if err != nil {
		panic(err)
	}
	defer fcsv.Close()

	// read csv
	r := csv.NewReader(fcsv)
	for {
		record, err := r.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			panic(err)
		}
		processWord(record)
	}
}

func main() {
	defer cs2t.Close()
	processWordsCSV(lib.WordsCSV1Path)
	processWordsCSV(lib.WordsCSV2Path)
}