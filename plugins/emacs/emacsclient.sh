#!/bin/sh

_emacsfun()
{
    # get list of emacs frames.
    frameslist=`emacsclient --alternate-editor '' --eval '(frame-list)' 2>/dev/null | egrep -o '(frame)+'`

    if [ "$(echo "$frameslist" | sed -n '$=')" -ge 2 ] ;then
        # prevent creating another X frame if there is at least one present.
        exec emacsclient --alternate-editor "" "$@" 2>/dev/null
    else
        # Create one if there is no X window yet.
        exec emacsclient --alternate-editor "" --create-frame "$@" 2>/dev/null
    fi
}


# adopted from https://github.com/davidshepherd7/emacs-read-stdin/blob/master/emacs-read-stdin.sh
# If the second argument is - then write stdin to a tempfile and open the
# tempfile. (first argument will be `--no-wait` passed in by the plugin.zsh)
if [ "$#" -ge "2" -a "$2" = "-" ]
then
    tempfile="$(mktemp --tmpdir emacs-stdin-$USER.XXXXXXX 2>/dev/null \
                || mktemp -t emacs-stdin-$USER)" # support BSD mktemp
    cat - > "$tempfile"
    _emacsfun --no-wait $tempfile
else
    _emacsfun "$@"
fi
