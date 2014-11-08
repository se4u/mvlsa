"""Calculate what the dependencies should be depending on the filename
# The target usually is
# mc_CountPow075^CountPow039-truncatele200_100~E-fn-mo-po1-stnsubj-mi-biar,300_1e-5.mat
# The logic is that
# for v in views: according to dep_excl_incl logic: generate dependency name along with r

"""
# Created: 14 October 2014
__author__  = "Pushpendre Rastogi"
__contact__ = "pushpendre@jhu.edu"
import sys
import itertools

def should_include(v, dep_excl_incl, vcode):
    """Just include everything for now"""
    sign_to_look_for="@"
    instring = any((e in vcode) for e in dep_excl_incl.split(sign_to_look_for))
    if dep_excl_incl[0]=="E":
        "Now we are running in exclusion mode"
        return not instring
    else:
        return instring

target=sys.argv[1]
standep_list=sys.argv[2].split(",")
bitext_list=sys.argv[3].split(",")
outdir_name=sys.argv[4]
wiki_max=15
fnppdb_view=[("fnppdb_cooccurence_xl", "fn")]
morpho_view=[("morphology_cooccurence_inflection", "mo")]
wiki_view=[("polyglotwiki_cooccurence_%d"%e, "po%d"%e) for e in xrange(1,wiki_max+1)]
standep_view=[("agigastandep_cooccurence_%s"%e, "ag%s"%e) for e in standep_list]
mikobvgn_view=[("mikolov_cooccurence_intersect", "mi")]
bitext_view=[("bitext_cooccurence_%s"%e, "bi%s"%e) for e in bitext_list]
ppopt, rest=target.split("~")
dep_excl_incl, gcca_opt=rest.split(",")
dim, r, view_threshold = gcca_opt.split("_")
views=itertools.chain(fnppdb_view, morpho_view, wiki_view, standep_view,mikobvgn_view, bitext_view)

for v, vcode in views:
    if should_include(v, dep_excl_incl, vcode):
        mc_muc, nt, m =ppopt.split("_")
        n, t=nt.split("-")
        for n_ in n.split("^"):
            sys.stdout.write(outdir_name+r"/v5_indisvd_%s~%s~%s-%s~%s~%s.mat "%(v, mc_muc, n_, t, m, r))
