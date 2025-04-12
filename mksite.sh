#!/bin/sh

INPUT_DIR=$1
OUTPUT_DIR=$2
CSS_FILE_NAME="index.css"
INDEX_FILE="$OUTPUT_DIR/index.html"
BLOG_NAME="blog"
ASSETS_DIR="assets"

rm -rf "$OUTPUT_DIR/*"
mkdir -p "$OUTPUT_DIR"

    
echo "<html><head><title>$BLOG_NAME</title><link rel="icon" type="image/png" href="assets/images/favicon.png" /><link rel='stylesheet' type='text/css' href='$CSS_FILE_NAME' /></head>" > "$INDEX_FILE"
echo "<body><main><h1>$BLOG_NAME</h1><ul>" >> "$INDEX_FILE"

if [ -e "$CSS_FILE_NAME" ]; then
    cp $CSS_FILE_NAME $OUTPUT_DIR/$CSS_FILE_NAME
fi

cp -r "$ASSETS_DIR" "$OUTPUT_DIR/"

# Loop through markdown files in the directory
for mdfile in "$INPUT_DIR"/*.md; do
	filename=$(basename "$mdfile" .md)

	title=$(sed -n '/---/,/---/p' "$mdfile" | grep 'title:' | sed 's/title: //')
	date=$(sed -n '/---/,/---/p' "$mdfile" | grep 'date:' | sed 's/date: //')

	# Use filename as title if no title is found
	if [ -z "$title" ]; then
		title="$filename"
	fi

	# Convert markdown to HTML with Pandoc and MathJax
	pandoc "$mdfile" --to=html5 --mathjax --toc --standalone --template="page-template.html" --css="$CSS_FILE_NAME" -o "$OUTPUT_DIR/$filename.html"

	echo "<li><a href='$filename.html'>$title</a> ($date)</li>" >> "$INDEX_FILE"
done

echo "</ul><main></body></html>" >> "$INDEX_FILE"

echo "Conversion completed. Index file generated at $INDEX_FILE"
