#!/bin/sh

_emacsfun()
{
    if [ -z "$ALTERNATE_EDITOR" ]; then
        ALTERNATE_EDITOR="--alternate-editor=start-emacs-daemon"
    else
        ALTERNATE_EDITOR="-a \"$ALTERNATE_EDITOR\""
    fi
    if [ ! -z "$EMACS_DAEMON" ]; then
        EMACSCLIENT_DAEMON="-s $HOME/.emacs.d/server/$EMACS_DAEMON"
    fi

    # get list of emacs frames.
    frameslist=`emacsclient $EMACSCLIENT_DAEMON $ALTERNATE_EDITOR --eval '(frame-list)' 2>/dev/null | egrep -o '(frame)+'`

    if [ "$(echo "$frameslist" | sed -n '$=')" -ge 2 ]; then
        # prevent creating another X frame if there is at least one present.
        exec emacsclient $EMACSCLIENT_DAEMON $ALTERNATE_EDITOR "$@" 2>/dev/null
    else
        # Create one if there is no X window yet.
        exec emacsclient $EMACSCLIENT_DAEMON $ALTERNATE_EDITOR -c "$@"
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
