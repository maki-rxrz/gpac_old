#!/bin/sh
#source_path="$1"
cd "$1"

revision=""
svn_revision=""
git_svn_revision=""
git_revision=""
git_rev_hash=""
git_version=""

chk_exist_branch () {
    exist_branch=""
    remote_branches="$2"
    local_branch="$1"
    chk_exist="`git branch | grep $local_branch`"
    if test "$chk_exist" = "" ; then
        for branch in $remote_branches ; do
            chk_exist="`git branch -r | grep $branch`"
            if test "$chk_exist" != "" ; then
                exist_branch="remotes/$branch"
                break
            fi
        done
    else
        exist_branch="$local_branch"
    fi
    echo "$exist_branch"
}

if [ -d ".git" ]; then
 if which git >/dev/null
 then
    base_branch=$(chk_exist_branch "plain" "origin/plain svn/trunk")
    if test "$base_branch" != "" ; then
        svn_revision="`git log -1 $base_branch | grep git-svn-id: | sed -e 's/^.*@//' -e 's/ .*//'`"
        git_version="$svn_revision"
        # Check svn branch
        git_svn_revision="`git rev-list $base_branch | wc -l`"
        # Check master branch
        master_branch=$(chk_exist_branch "master" "origin/master")
        git_master_revision="`git rev-list $master_branch | wc -l`"
        # Check HEAD
        git_revision="`git rev-list HEAD | wc -l`"
        # Calculate diff numbers
        git_rev_diff="$(($git_revision-$git_svn_revision))"
        if [ $git_rev_diff != 0 ] ; then
            if [ $git_revision != $git_master_revision ] ; then
                git_rev_diff2="$(($git_revision-$git_master_revision))"
                git_rev_diff1="$(($git_rev_diff-$git_rev_diff2))"
                git_version="$git_version+$git_rev_diff1+$git_rev_diff2"
            else
                git_version="$git_version+$git_rev_diff"
            fi
        fi
        if git status | grep -q "modified:" ; then
            git_version="${git_version}M"
        fi
        git_rev_hash="`git rev-list HEAD -1 --abbrev-commit`"
        git_version="$git_version git-$git_rev_hash"
    fi
 else
    echo "Cannot find GIT revision" >&2
 fi
fi
if test "$svn_revision" = "" ; then
    svn_revision="4808"
    git_version="$svn_revision"
fi
revision=$svn_revision

cat > include/gpac/revision.h << EOF
#define GPAC_SVN_REVISION       "$svn_revision"
#define GPAC_GIT_SVN_REVISION   "$git_svn_revision"
#define GPAC_GIT_REVISION       "$git_revision"
#define GPAC_GIT_REV_HASH       "$git_rev_hash"
#define GPAC_GIT_VERSION        "$git_version"
EOF

echo $revision
