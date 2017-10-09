
AGL_HOME=`pwd`
DL_DIR=~/gen3/downloads


#BRANCH="master"
BRANCH="dab"
#BRANCH="chinook"


#BOARD="m3ulcb"
BOARD="h3ulcb"

CHROMIUM="NO"
KINGFISHER="NO"

DAB_MANIFEST="4.0.1"
CHINOOK_MANIFEST="3.0.5"

CHROME_BRANCH="ozone/wayland/20170928"
COGENT_BRANCH="v2.23.0"

AGL_FEATURE="agl-devel agl-demo agl-appfw-smack agl-netboot"


if [ $BRANCH = "master" ]; then
   CHROMIUM="NO"
   KINGFISHER="NO"
   COGENT_BRANCH="v2.23.0"
elif [ $BRANCH = "chinook" ] ;then
   CHROMIUM="NO"
   KINGFISHER="NO"
fi


get_agl_source()
{
if [ $BRANCH = "master" ]; then
	repo init -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo  -m default.xml
elif [ $BRANCH = "dab" ]; then
	repo init -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo -m dab_${DAB_MANIFEST}.xml
elif [ $BRANCH = "chinook" ] ;then
	repo init -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo  -m chinook_${CHINOOK_MANIFEST}.xml
fi

cp .repo/manifest.xml manifest.xml.org
sed -e "/Freescale/d" manifest.xml.org > .repo/manifest.xml

repo sync -j10

}

get_additional_reops()
{
	if [ $CHROMIUM = "YES" ] ;then
		git clone https://github.com/Igalia/meta-browser.git
		pushd meta-browser
		git checkout -b tmp $CHROME_BRANCH
		popd
		git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
	fi

	if [ $KINGFISHER = "YES" ] ;then
		git clone https://github.com/CogentEmbedded/meta-rcar.git
		pushd meta-rcar
		git checkout -b tmp $COGENT_BRANCH
		popd
	fi

}

set_agl_script()
{
	source meta-agl/scripts/aglsetup.sh -m $BOARD -b build_${BOARD} ${AGL_FEATURE}
}

add_local_conf()
{
	if [ $CHROMIUM = "YES" ] ;then
		cat ../../env-script/chrome.bblayer.conf >> conf/bblayers.conf
		cat ../../env-script/chrome.local.conf >> conf/local.conf

		echo ""
		echo "CHROMIUM_GN_PATH=\"$AGL_HOME/depot_tools\"" >> conf/local.conf
	fi


}


#### main ###

get_agl_source

get_additional_reops

set_agl_script

add_local_conf

echo "DL_DIR=\"$DL_DIR\"" >> conf/local.conf

