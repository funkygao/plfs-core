#!/usr/bin/env perl
#
# The Self-* Storage System Project
# Copyright (c) 2004-2011, Carnegie Mellon University.
# All rights reserved.
# http://www.pdl.cmu.edu/  (Parallel Data Lab at Carnegie Mellon)
#
# This software is being provided by the copyright holders under the
# following license. By obtaining, using and/or copying this software,
# you agree that you have read, understood, and will comply with the
# following terms and conditions:
#
# Permission to reproduce, use, and prepare derivative works of this
# software is granted provided the copyright and "No Warranty" statements
# are included with all reproductions and derivative works and associated
# documentation. This software may also be redistributed without charge
# provided that the copyright and "No Warranty" statements are included
# in all redistributions.
#
# NO WARRANTY. THIS SOFTWARE IS FURNISHED ON AN "AS IS" BASIS.
# CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER
# EXPRESSED OR IMPLIED AS TO THE MATTER INCLUDING, BUT NOT LIMITED
# TO: WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY
# OF RESULTS OR RESULTS OBTAINED FROM USE OF THIS SOFTWARE. CARNEGIE
# MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT
# TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# COPYRIGHT HOLDERS WILL BEAR NO LIABILITY FOR ANY USE OF THIS SOFTWARE
# OR DOCUMENTATION.
#

# makefacs.pl  autogen mlogfacs.h file based on facs list

@facs = (
# names:
#  abbreviated     long
     "PLFS"     => "plfs_misc",
     "INT"      => "internal",
     "CON"      => "container",
     "IDX"      => "index",
     "WF"       => "writefile",
     "FOP"      => "fileops",
     "UT"       => "utilities",
     "STO"      => "store",
     "FUSE"     => "FUSE",
     "MPI"      => "MPI",
);

@mloglvls = (
#        format: main_name:alias1:alias2:...
    "MLOG_EMERG",         #  emergency 
    "MLOG_ALERT",         #  alert 
    "MLOG_CRIT",          #  critical 
    "MLOG_ERR",           #  error 
    "MLOG_WARN",          #  warning 
    "MLOG_NOTE",          #  notice 
    "MLOG_INFO",          #  info 
    "MLOG_DBG",           #  all debug streams 
    "MLOG_DBG0:DAPI",     #  debug stream 0 
    "MLOG_DBG1:DINTAPI",  #  debug stream 1 
    "MLOG_DBG2:DCOMMON",  #  debug stream 2 
    "MLOG_DBG3:DRARE",    #  debug stream 3 
);

######################################################################
# end of configuration section
######################################################################

die "odd sized facs[] array" if (($#facs+1) & 1);

open(P, ">mlogfacs.h_NEW") || die "cannot open mlogfacs.h_NEW ($!)";

$_ = <<EOD;
/*
 * The Self-* Storage System Project
 * Copyright (c) 2011, Carnegie Mellon University.
 * All rights reserved.
 * http://www.pdl.cmu.edu/  (Parallel Data Lab at Carnegie Mellon)
 *
 * This software is being provided by the copyright holders under the
 * following license. By obtaining, using and/or copying this software,
 * you agree that you have read, understood, and will comply with the
 * following terms and conditions:
 *
 * Permission to reproduce, use, and prepare derivative works of this
 * software is granted provided the copyright and "No Warranty" statements
 * are included with all reproductions and derivative works and associated
 * documentation. This software may also be redistributed without charge
 * provided that the copyright and "No Warranty" statements are included
 * in all redistributions.
 *
 * NO WARRANTY. THIS SOFTWARE IS FURNISHED ON AN "AS IS" BASIS.
 * CARNEGIE MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER
 * EXPRESSED OR IMPLIED AS TO THE MATTER INCLUDING, BUT NOT LIMITED
 * TO: WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY
 * OF RESULTS OR RESULTS OBTAINED FROM USE OF THIS SOFTWARE. CARNEGIE
 * MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT
 * TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
 * COPYRIGHT HOLDERS WILL BEAR NO LIABILITY FOR ANY USE OF THIS SOFTWARE
 * OR DOCUMENTATION.
 */

/*
 * facility names.
 *
 * DO NOT EDIT-- this file is automatically generated.
 */

#ifndef _MLOGFACS_H_
#define _MLOGFACS_H_

#include "mlog.h"    /* for MLOG_ defines */

EOD
safeprint($_);

#
# generate array of facility names, if requested
#
safeprint("#if defined(MLOG_FACSARRAY) || defined(MLOG_AFACSARRAY)\n");
safeprint("static const char *mlog_facsarray[] = {\n");
safeprintf("    %-16s /* %d -- MLOG default fac */\n", '"' . "MLOG" . '",', 0);
for ($lcv = 0 ; $lcv <= $#facs ; $lcv += 2) {
    safeprintf("    %-16s /* %d */\n", '"' . $facs[$lcv] . '",', 
         ($lcv / 2) + 1);
}
safeprintf("    %-16s /* %d */\n", "0,", ($lcv / 2) + 1);  # end marker
safeprint("};\n#endif /* MLOG_FACSARRAY || MLOG_AFACSARRAY */\n\n");

safeprint("#if defined(MLOG_FACSARRAY) || defined(MLOG_LFACSARRAY)\n");
safeprint("static const char *mlog_lfacsarray[] = {\n");
safeprintf("    %-16s /* %d -- MLOG default fac */\n", '"' . "MLOG" . '",', 0);
for ($lcv = 0 ; $lcv <= $#facs ; $lcv += 2) {
    safeprintf("    %-16s /* %d */\n", '"' . $facs[$lcv+1] . '",', 
         ($lcv / 2) + 1);
}
safeprintf("    %-16s /* %d */\n", "0,", ($lcv / 2) + 1);  # end marker
safeprint("};\n#endif /* MLOG_LFACSARRAY || MLOG_LFACSARRAY */\n\n");

safeprint("/*\n * standard facility defines\n */\n");
for ($lcv = 0 ; $lcv <= $#facs ; $lcv+= 2) {
    safeprintf("#define MLOGFAC_%-8s %2d /* %s */\n", $facs[$lcv], 
           ($lcv / 2) + 1, $facs[$lcv+1]);
}
safeprint("\n");

#
# generate shortcut mlog vars
#
for ($lcv = 0 ; $lcv <= $#facs ; $lcv += 2) {
    safeprint("/*\n * $facs[$lcv+1] MLOG levels\n */\n");
    foreach $m (@mloglvls) {
        @mlnames = split(/:/, $m);
        $mlmain = shift(@mlnames);
        $scut = $mlmain;
        $scut =~ s/MLOG_//;
        $scut = $facs[$lcv] . "_$scut";
        safeprintf("#define %-16s (%d | %s)\n", $scut, ($lcv / 2) + 1, $mlmain);
        foreach $malias (@mlnames) {
            safeprintf("#define %-16s  %s\n", $facs[$lcv] . "_" . $malias, 
                       $scut);
        }
    }
    safeprint("\n");
}

#
# wrap it up
#
safeprint("#endif /* _MLOGFACS_H_ */\n");
if (!close P || !rename("mlogfacs.h_NEW", "mlogfacs.h")) {
    print "CLOSE ERROR: $!, aborting\n";
    unlink("mlogfacs.h_NEW");
    exit(1);
}
exit(0);

#
# safeprintf: printf something, but abort if we have an error
#
sub safeprintf {
    my($rv);
    $rv = printf P @_;
    unless ($rv) {
        print "PRINTF ERROR: $!, aborting\n";
        unlink("mlogfacs.h_NEW");
        exit(1);
    }
}

#
# safeprint: print something, but abort if we have an error
#
sub safeprint {
    my($rv);
    $rv = print P @_;
    unless ($rv) {
        print "PRINT ERROR: $!, aborting\n";
        unlink("mlogfacs.h_NEW");
        exit(1);
    }
}
