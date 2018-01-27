#!/usr/bin/perl

# tartan-3.2.pl
# Kaeding 2011aug01
# last modified 2011aug24

$arandomizer = 15;
$mrandomizer = .1;
$depth = 1;
if ($ARGV[1] ne "") {
  $depth = $ARGV[1];
  }

open (infile, "$ARGV[0]");
while (<infile>) {
  $line = ($_);
  $line =~ s/\n//;
  if (substr ($line, 0, 7) eq "Pallet:") {
    printf "\nPallet:\n\n";
    ($dummy, $pallet) = split (/:/, $line);
    $pallet =~ s/^ *//;
    @palletentries = split (/;/, $pallet);
    $numcolors = 0;
    foreach $i (@palletentries) {
      ($colorcode[$numcolors], $dummy) = split (/=/, $i);
      $colorcode[$numcolors] =~ s/^ *//;
      $colorhexes[$numcolors] = substr ($dummy, 0, 6);
      $colorname[$numcolors] = substr ($dummy, 6);
      $colorname[$numcolors] = lc ($colorname[$numcolors]);
      for ($j=0; $j<3; $j++) {
        $colorhex[$numcolors][$j] = substr ($colorhexes[$numcolors], 2*$j, 2);
        $colordec[$numcolors][$j] = hex ($colorhex[$numcolors][$j]);
        }
      printf "  %16s  %4s  %s  %3d,%3d,%3d\n", $colorname[$numcolors], $colorcode[$numcolors],
          $colorhexes[$numcolors],
          $colordec[$numcolors][0], $colordec[$numcolors][1], $colordec[$numcolors][2];
      $numcolors++;
      }
    }
  elsif (substr ($line, 0, 12) eq "Threadcount:") {
    ($dummy, $threadcount) = split (/:/, $line);
    $threadcount =~ s/ //g;
    }
  elsif (substr ($line, 0, 1) eq "#") {
    # it's a comment
    }
  else {
    $name = $line;
    }
  }
close (infile);

printf "\nThreadcounts:\n\n";
# printf "        $threadcount\n";
$tcount[0] = $tcount[1] = 0;
$tcindex = 0;
$xydiffer = "no";
while (length ($threadcount) > 0) {
  if (substr ($threadcount, 0, 1) eq ".") {
    $xydiffer = "yes";
    $tcindex = 1;
    printf "\n    in other direction:\n\n";
    $threadcount = substr ($threadcount, 1);
    }
  for ($k=3; $k>0; $k--) {
    for ($i=0; $i<$numcolors; $i++) {
      if (substr ($threadcount, 0, $k) eq $colorcode[$i]) {
        $threadcolorindex[$tcindex][$tcount[$tcindex]] = $i;
        $threadcount = substr ($threadcount, $k);
        }
      }
    }
  if (substr ($threadcount, 0, 1) eq "/") {
    $symmetric = "yes";
    $threadcount = substr ($threadcount, 1);
    }
  else {
    $symmetric = "no";
    }
  if ( ($temp = substr ($threadcount, 0, 3)) eq 1*$temp) {
    $threadnum[$tcindex][$tcount[$tcindex]] = $temp;
    $threadcount = substr ($threadcount, 3);
    }
  elsif (($temp = substr ($threadcount, 0, 2)) eq 1*$temp) {
    $threadnum[$tcindex][$tcount[$tcindex]] = $temp;
    $threadcount = substr ($threadcount, 2);
    }
  elsif (($temp = substr ($threadcount, 0, 1)) eq 1*$temp) {
    $threadnum[$tcindex][$tcount[$tcindex]] = $temp;
    $threadcount = substr ($threadcount, 1);
    }
  printf "  %16s  %3d", $colorname[$threadcolorindex[$tcindex][$tcount[$tcindex]]], $threadnum[$tcindex][$tcount[$tcindex]];
  if ($symmetric eq "yes") {
    printf "    (pivot)";
    }
  printf "\n";
  $tcount[$tcindex]++;
  }
printf "\nSymmetric?  $symmetric\n\n";
printf "Warp and weft differ?  $xydiffer\n\n";

$tcindex = 0;
xy:
$threads[$tcindex] = 0;
for ($i=0; $i<$tcount[$tcindex]; $i++) {
  for ($j=0; $j<$threadnum[$tcindex][$i]; $j++) {
    for ($k=0; $k<3; $k++) {
      $sett[$tcindex][$threads[$tcindex]][$k] = $colordec[$threadcolorindex[$tcindex][$i]][$k];
      }
    $threads[$tcindex]++;
    }
  }
if ($symmetric eq "yes") {
  for ($i=$tcount[$tcindex]-2; $i>0; $i--) {
    for ($j=0; $j<$threadnum[$tcindex][$i]; $j++) {
      for ($k=0; $k<3; $k++) {
        $sett[$tcindex][$threads[$tcindex]][$k] = $colordec[$threadcolorindex[$tcindex][$i]][$k];
        }
      $threads[$tcindex]++;
      }
    }
  }
if (($xydiffer eq "yes") && ($tcindex == 0)) {
  $tcindex = 1;
  goto xy;
  }
elsif ($xydiffer eq "no") {
  for ($i=0; $i<$threads[0]; $i++) {
    for ($j=0; $j<3; $j++) {
      $sett[1][$i][$j] = $sett[0][$i][$j];
      $threads[1] = $threads[0];
      }
    }
  }

printf "Sett has $threads[0] x $threads[1] threads\n\n";

for ($i=0; $i<2; $i++) {
  while ($threads[$i]%4 != 0) {
    for ($j=0; $j<$threads[$i]; $j++) {
      for ($k=0; $k<3; $k++) {
        $sett[$i][$threads[$i]+$j][$k] = $sett[$i][$j][$k];
        }
      }
    $threads[$i] *= 2;
    }
  }

printf "Creating file \"$name.ppm\"\n\n";
open (outfile, ">$name.ppm");
printf outfile "P3\n";
printf outfile "# $name tartan generated by tartan-3.1.pl\n";
$dummy0 = $threads[0] * 2;
$dummy1 = $threads[1] * 2;
printf outfile "$dummy0 $dummy1\n";
printf outfile "255\n";
$z = 0;
for ($i=0; $i<$threads[1]; $i++) {
  for ($j=0; $j<$threads[0]; $j++) {
    if ((($i + $j)/2)%2 == 0) {
      $m = $i + 100;
      while ($m >= $threads[1]) {
        $m -= $threads[1];
        }
      $divisor = 1;
      if (($i + $j) % 4 == 1) {
        $divisor = 1 + $depth;
        }
      for ($k=0; $k<3; $k++) {
        $dummy = ($sett[1][$m][$k] * (1 + $mrandomizer*rand() - $mrandomizer/2)
               + $arandomizer*rand() - $arandomizer/2);
        if ($dummy < 0) { $dummy = 0; }
        if ($dummy > 255) { $dummy = 255; }
        printf outfile "%4d", $dummy;
        }
      for ($k=0; $k<3; $k++) {
        $dummy = ($sett[1][$m][$k] * (1 + $mrandomizer*rand() - $mrandomizer/2)
               + $arandomizer*rand() - $arandomizer/2) / $divisor;
        if ($dummy < 0) { $dummy = 0; }
        if ($dummy > 255) { $dummy = 255; }
        printf outfile "%4d", $dummy;
        }
      }
    else {
      $m = $j + 40;
      while ($m >= $threads[0]) {
        $m -= $threads[0];
        }
      for ($k=0; $k<3; $k++) {
        $dummy = ($sett[0][$m][$k] * (1 + $mrandomizer*rand() - $mrandomizer/2)
               + $arandomizer*rand() - $arandomizer/2);
        if ($dummy < 0) { $dummy = 0; }
        if ($dummy > 255) { $dummy = 255; }
        printf outfile "%4d", $dummy;
        }
      for ($k=0; $k<3; $k++) {
        $dummy = ($sett[0][$m][$k] * (1 + $mrandomizer*rand() - $mrandomizer/2)
               + $arandomizer*rand() - $arandomizer/2) / (1 + $depth);
        if ($dummy < 0) { $dummy = 0; }
        if ($dummy > 255) { $dummy = 255; }
        printf outfile "%4d", $dummy;
        }
      }
    $z++;
    if ($z == 6) {
      printf outfile "\n";
      $z = 0;
      }
    }
  for ($j=0; $j<$threads[0]; $j++) {
    if ((($i + $j)/2)%2 == 0) {
      $m = $i + 100;
      while ($m >= $threads[1]) {
        $m -= $threads[1];
        }
      $divisor = 1 + $depth;
      if (($i + $j) % 4 == 1) {
        $divisor = 1 + 2 * $depth;
        }
      for ($k=0; $k<3; $k++) {
        $dummy = ($sett[1][$m][$k] * (1 + $mrandomizer*rand() - $mrandomizer/2)
               + $arandomizer*rand() - $arandomizer/2) / (1 + $depth);
        if ($dummy < 0) { $dummy = 0; }
        if ($dummy > 255) { $dummy = 255; }
        printf outfile "%4d", $dummy;
        }
      for ($k=0; $k<3; $k++) {
        $dummy = ($sett[1][$m][$k] * (1 + $mrandomizer*rand() - $mrandomizer/2)
               + $arandomizer*rand() - $arandomizer/2) / $divisor;
        if ($dummy < 0) { $dummy = 0; }
        if ($dummy > 255) { $dummy = 255; }
        printf outfile "%4d", $dummy;
        }
      }
    else {
      $m = $j + 40;
      while ($m >= $threads[0]) {
        $m -= $threads[0];
        }
      $divisor = 1;
      if (($i + $j) % 4 == 3) {
        $divisor = 1 + $depth;
        }
      for ($k=0; $k<3; $k++) {
        $dummy = ($sett[0][$m][$k] * (1 + $mrandomizer*rand() - $mrandomizer/2)
               + $arandomizer*rand() - $arandomizer/2) / $divisor;
        if ($dummy < 0) { $dummy = 0; }
        if ($dummy > 255) { $dummy = 255; }
        printf outfile "%4d", $dummy;
        }
      $divisor = 1 + $depth;
      if (($i + $j) % 4 == 3) {
        $divisor = 1 + 2 * $depth;
        }
      for ($k=0; $k<3; $k++) {
        $dummy = ($sett[0][$m][$k] * (1 + $mrandomizer*rand() - $mrandomizer/2)
               + $arandomizer*rand() - $arandomizer/2) / $divisor;
        if ($dummy < 0) { $dummy = 0; }
        if ($dummy > 255) { $dummy = 255; }
        printf outfile "%4d", $dummy;
        }
      }
    $z++;
    if ($z == 6) {
      printf outfile "\n";
      $z = 0;
      }
    }
  }
printf outfile "\n";
close (outfile);

# end
