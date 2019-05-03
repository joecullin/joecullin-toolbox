#!/usr/bin/perl --

# word-to-html converter for TW-1325
# Copy whole doc to clipboard on a mac, then run this on your mac.

use strict;
use warnings;

my $doc = getClipboard();
my $html = $doc;

# print "\n$html\n"; exit;

# The whole mess in <head>
$html =~ s{<head>.*?</head>}{}sg;

# Remove non-href anchors
$html =~ s{<a\s+name.*?>(.*?)</a>}{$1}sg;

# Collapse onto one line
$html =~ s{<a\s+href}{<a href}sg;

# Remove all span tags
$html =~ s{</?span.*?>}{}sg;

# Remove all <o> tags
$html =~ s{</?o:p>}{}sg;

# Remove comments
$html =~ s{<!.*?>}{}sg;
$html =~ s{<-.*?>}{}sg;

# Remove all attributes, except from anchor tags.
$html =~ s{<([^a][a-z]*).*?>}{<$1>}sg;

# Convert numbered list to ol
$html =~ s{<p>\d+[.]&nbsp;&nbsp;&nbsp;&nbsp;\s*(.*?)</p>}{<li>$1</li>}sg;
$html =~ s{(<li>.*?)(\s*<p)}{<ol>$1</ol>$2}sg;

# Remove unwanted unicode characters
$html =~ s{\xc2\xad}{}sg;  # logical "not" sign

# Remove empty paragraphs
$html =~ s{<p></p>}{}sg;
$html =~ s{<p>&nbsp;</p>}{}sg;
$html =~ s{<p><b>&nbsp;</b></p>}{}sg;

# Remove extra line breaks in paragraphs and list elements.
$html =~ s{<p>(.*?)</p>}{'<p>' . removeLineBreaks($1) . '</p>'}esg;
$html =~ s{<li>(.*?)</li>}{'<li>' . removeLineBreaks($1) . '</li>'}esg;

# Remove paragraphs from table cells
$html =~ s{<td>\s*<p>(.*?)</p>\s*</td>}{<td>$1</td>}sg;

# Turn bold paragraphs into headings
$html =~ s{<p><b>([^<]*)</b></p>}{<h2>$1</h2>}g;

# Remove multiple consecutive empty lines
$html =~ s{\n\n+}{\n\n}g;

# Remove empty lines in tables
$html =~ s{</td>\n}{</td>}sg;

# Turn first table row into table headers.
$html =~ s{(<table>\s*<tr>)(.*?)</tr>}{$1 . tableHeaders($2) . '</tr>'}seg;

print $html . "\n";

# Write the result back to the clipboard.
if (0){
	if (open(my $write_clipboard, '|-', 'pbcopy')){
		print $write_clipboard $html;
		close $write_clipboard;
	}
	else{
		die("Error writing to clipboard.\n");
	}
}
exit;

sub tableHeaders
{
	my $row = shift;
	$row =~ s{<td><b>(.*?)</b></td>}{<th>$1</th>}sg;
	return $row;	
}

sub removeLineBreaks
{
	my $string = shift;
	$string =~ s/\n/ /sg;
	$string =~ s/\r/ /sg;
	$string =~ s/^\s*(.*?)\s*$/$1/sg;
	return $string;
}

sub getClipboard
{
	# This is useful for troubleshooting.
	my $dummy = qq{
<meta name=Originator content="Microsoft Word 14">
<link rel=File-List
href="file://localhost/private/var/folders/81/v9_rq9y90z51lk28vdy364s80000gn/T/TemporaryItems/msoclip/0/clip_filelist.xml">
<!--[if gte mso 9]><xml>
};
	# return $dummy;

	# This doesn't include html formatting.
	# my $clipboard = qx{pbpaste};

	my $clipboard_xml = qx{osascript -e 'the clipboard as «class HTML»' |   perl -ne 'print chr foreach unpack("C*",pack("H*",substr(\$_,11,-3)))'};

	return $clipboard_xml;
}
