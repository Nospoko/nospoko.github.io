#!/bin/bash
set -e

SOURCE_BRANCH="slave"
TARGET_BRANCH="master"

REPO=`git config remote.origin.url`
# SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
# TARGET_REPO="https:\/\/github.com\/Nospoko\/nospoko.github.io.git"
# TARGET_REPO="git@github.com:Nospoko\/nospoko.github.io.git"
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`

# Clone the existing gh-pages for this repo into out/
# Create a new empty branch if gh-pages doesn't exist yet (should only happen on first deply)
git clone $REPO out
cd out
git checkout $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH
cd ..

# Clean out existing contents
rm -rf out/**/* || exit 0
rm -rf .asset-cache

bundle exec jekyll build --destination out

cd out
git config user.name "Travis CI"
git config user.email "$COMMIT_AUTHOR_EMAIL"

# Add cname for the dns something
echo nospoko.com > CNAME

# Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc
ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in ../deploy_key.enc -out deploy_key -d
chmod 600 deploy_key
eval `ssh-agent -s`
ssh-add deploy_key

git add -A
git commit -m "Deploy to GitHub Pages: ${SHA}"

echo "Pushing to GitHub..."

# Now that we're all set up, we can push.
git push --force $SSH_REPO $TARGET_BRANCH

echo $ENCRYPTION_LABEL

echo "Done!"
