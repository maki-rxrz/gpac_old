#!/bin/sh
#source_path="$1"
cd "$1"

revision=""
svn_revision=""
git_svn_revision=""
git_revision=""
git_rev_hash=""
git_version=""

if [ -d ".git" ]; then
 if which git >/dev/null
 then
    base_branch=""
    remote_branches="origin/plain svn/trunk"
    local_branch="plain"
    chk_exist="`git branch | grep $local_branch`"
    if test "$chk_exist" = "" ; then
        for branch in $remote_branches ; do
            chk_exist="`git branch -r | grep $branch`"
            if test "$chk_exist" != "" ; then
                base_branch="remotes/$branch"
                break
            fi
        done
    else
        base_branch="$local_branch"
    fi
    if test "$base_branch" != "" ; then
        svn_revision="`git log -1 $base_branch | grep git-svn-id: | sed -e 's/^.*@//' -e 's/ .*//'`"
        git_version="$svn_revision"
        git_svn_revision="`git rev-list $base_branch | wc -l`"
        git_revision="`git rev-list HEAD | wc -l`"
        git_rev_diff="`git rev-list $base_branch | wc -l`"
        git_rev_diff="$(($git_revision-$git_rev_diff))"
        if [ $git_rev_diff != 0 ] ; then
            git_version="$git_version+$git_rev_diff"
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
    svn_revision="4704"
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
