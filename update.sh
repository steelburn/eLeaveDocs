#!/usr/bin/env bash

WWWDIR=/www/html
KARMAFILES="karma.conf.js src/karma.conf.js"
SYNCDIRS="documentation html-report"
REPOLIST="eLeaveCore eleave-v3 eLeave_admin-V3 eLeave_tenant-V1 eLeaveTenantCore eLeaveForgetPasswordCore"

# Packages needed for rework of default index.html file
BULMAREPO=https://github.com/jgthms/bulma.git
FA_VER=5.10.2
FA_BASE_SRC=fontawesome-free-${FA_VER}-web
FA_URL=https://use.fontawesome.com/releases/v5.10.2/${FA_BASE_SRC}.zip

firstRun()
{
  for REPO in ${REPOLIST}; do
    if [ ! -d ${REPO} ]; then
      git clone https://github.com/zencomputersystems/${REPO}.git
    fi
  done
}

correctKarma() 
{
  for FILE in ${KARMAFILES}; do
    if [ -f ${FILE} ]; then
      sed -i 's/singleRun: false/singleRun: true/' ${FILE}
      sed -i "s/\'Chrome\'/\'ChromeHeadless\'/g" ${FILE}
    fi
  done
}

syncDirs()
{
  for DIR in ${SYNCDIRS}; do
    if [ -d ${DIR} ]; then
      CDIR=${WWWDIR}/${d}/${DIR}
      mkdir -p ${CDIR}
      rsync -r --del ${DIR}/ ${CDIR}
    fi
  done
}

getBulma()
{
  pushd ${WWWDIR}
  if [ ! -d ${WWWDIR}/bulma ]; then
    echo "Getting Bulma installed..."
    git clone ${BULMAREPO} ${WWWDIR}/bulma
  fi
  popd
}

getFontAwesome()
{
  pushd ${WWWDIR}
  if [ ! -d ${WWWDIR}/fontawesome ]; then
    echo "Getting our own copy of Font Awesome..."
    wget -c -O ${FA_BASE_SRC}.zip ${FA_URL} && \
        unzip ${WWWDIR}/${FA_BASE_SRC}.zip && \
        mv ${FA_BASE_SRC} fontawesome
  fi
  popd
}

htmlHeader()
{
cat <<EOF
<!DOCTYPE html>
<html lang="en">
 <head>
  <title>eLeave Documentation & Testing</title>
  <meta http-equiv="refresh" content="20">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  
  <link rel="stylesheet" href="/bulma/css/bulma.min.css">
  <script defer src="/fontawesome/js/all.js"></script>
 </head>
 <body>
  <section class="hero ">
  <div class="tile is-ancestor">
    <div class="tile is-parent">
    <article class="tile box has-background-black-ter">
      <div class="hero-head has-text-light title">eLeave</div>
      <div class="hero-body subtitle">Documentation & Test Results</div>
    </article>
    </div>
 </div>
EOF
}

htmlFooter()
{
cat << EOF
 <div class="hero-foot">
 <footer class="footer">
  <div class="content has-text-centered">
   <p>eLeave 2019. ZEN's R&D team </p>
   <p><a href="http://www.zen.com.my">Zen Computer Systems Sdn Bhd</a></p>
  </div>
 </footer>
 </div>
 </section>
 </body>
</html>
EOF
}

showSubReports() 
{
 CHECKDIR=$1
 for RDIR in ${SYNCDIRS}; do
  if [ -d ${WWWDIR}/${CHECKDIR}/${RDIR} ]; then
   echo "<a class="button is-link" href=\"/${CHECKDIR}/${RDIR}\"><i class=\"fas fa-folder\"></i> ${RDIR}</a>"
  else
   echo "<a class=\"button is-danger\" disabled><i class=\"fas fa-times-circle\"></i>${RDIR}</a>"
  fi
 done
}

indexListing()
{
 echo "<div class=\"tile is-ancestor\">"
 echo " <div class=\"tile is-horizontal is-12\">"
 for DIR in ${REPOLIST}; do
  if [ -d ${WWWDIR}/${DIR} ]; then
   echo "  <div class=\"tile is-parent\">"
   echo "   <article class=\"tile is-child notification box is-primary\">"
   echo "    <div class=\"message-header\"><i class=\"fas fa-folder-open\"></i>${DIR}</div>"
   showSubReports $DIR
   if [ "${DIR}" == "${WORKINGREPO}" ]; then
     echo "    <br /><br /><progress class=\"progress is-medium is-info\" max=\"100\">60%</progress>"
   fi
   echo "   </article>"
   echo "  </div>"
   LISTING="yes"
  fi
  if [ ! -d ${WWWDIR}/${DIR} ] && [ "${DIR}" == "${WORKINGREPO}" ]; then
   echo "  <div class=\"tile is-parent\">"
   echo "   <article class=\"tile is-child notification box is-primary\">"
   echo "    <div class=\"message-header\">${DIR}</div>"
   echo "    <br /><br /><progress class=\"progress is-medium is-info\" max=\"100\">60%</progress>"
   echo "   </article>"
   echo "  </div>"
  fi
 done
 if [ -z $LISTING ]; then
 cat << EOF
 <div class="tile is-parent">
  <article class="tile is-child notification is-danger">        
  <p class="title">The index file is under construction.</p> <p class="subtitle">Please check back in a while.</p> 
  </article>
 </div>
EOF
 fi
 echo " </div>"
 echo "</div>"

}

writeHTML()
{
htmlHeader > ${WWWDIR}/index.html
indexListing >> ${WWWDIR}/index.html
htmlFooter >> ${WWWDIR}/index.html
}

main()
{
  for d in * ; do
    if [ -d ${d} ]; then
#      if [ ! -d ${WWWDIR}/${d} ]; then
        WORKINGREPO=${d}
	writeHTML;
#      fi
      pushd ${d}
      git stash && git stash drop && UPDATES=$(git pull)
      if [ "${UPDATES}" != "Already up to date." ]; then
        npm i && npm audit fix
        npm run doc:build
        correctKarma
        npm run test
#        if [ -f angular.json ]; then
#          npm run-script build
#        fi
        echo "Synchronizing related ${d} directories..."
        syncDirs
      else
	echo ${UPDATES}
      fi
      unset WORKINGDREPO
      popd
    fi
  done
}

########################################
## BEGIN

# Call the functions to start the script
getBulma
getFontAwesome
writeHTML
firstRun
RUN=1
while [ ${RUN} -eq 1 ]
do
  main
  writeHTML
  sleep 1h
done
## END
#######################################
