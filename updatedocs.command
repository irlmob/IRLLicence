#!/usr/bin/env bash
###
### WARNING WORK ONLY with cutom domain.
### See https://docs.github.com/articles/using-a-custom-domain-with-github-pages/ for more details
###
### Comit your files, then in the repo, go to Settings / Pages 
###  - Source should be branch/docs
###  - Custom domain should be <your custom subdomain>
###
### Don't forget to add the CNAME to your DNS zone
###

export GITHUBNAME=charlymr
export SCHEME=IRLLicence
export CUSTOMDOMAIN=doc-irllicence.irlmobile.com
rm -rf docs
mkdir -p docs

xcodebuild docbuild                     \
  -scheme "${SCHEME}"                   \
  -destination generic/platform=iOS     \
  -derivedDataPath DerivedData

rm -rf ${SCHEME}.doccarchive

find DerivedData                        \
  -name "${SCHEME}.doccarchive"         \
  -exec cp -R {} ./ \;

rm -rf DerivedData
rm -rf docs

mv "${SCHEME}.doccarchive" docs
echo "${CUSTOMDOMAIN}" > docs/CNAME

mkdir -p docs/documentation
cp -pr docs/index.html docs/documentation/

mkdir -p docs/tutorial
cp -pr docs/index.html docs/tutorial/

cp -pr docs/data/documentation/*.json docs/data/documentation.json

echo '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">' > docs/index.html
echo '<html<head><META HTTP-EQUIV="refresh" content="0;URL=/documentation"></head></html>' >> docs/index.html

rm -rf DerivedData

