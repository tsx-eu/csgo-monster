#!/bin/bash

function radar() {
	rm -Rf $1
	mkdir $1
	for i in {0..359..6}; do
		convert $1.png -distort SRT $i +repage $1/${i}.png
	done
}

radar cyan
radar green
radar red
radar orange
radar yellow
