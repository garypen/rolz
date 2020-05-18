#! /bin/bash


if [ "${BASH_VERSINFO:-0}" -lt 4 ]; then
    echo "requires bash 4 or newer"
    exit 2
fi

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.
JQ_CMD=jq
IFS=","
declare -A Init

show_help() {
cat <<EOF

  initiative.sh [-f <characters>] -r <room id> [<name init>, <name init>...]

Description

  Uses the rolz API to generatate initiative for the supplied participants

  The results are sorted and posted back to the rolz dice room.

Examples

  intiative.sh -f party.txt -r 12345678 orc -1  -- generates initiative
                                                -- for the contents of
                                                -- party.txt and orc

Options

  <name init>      Pairings of names and initiative adjustments.
                   init must be numeric and optionally preceded by a
                   minus sign.

  -f <characters>  File of character details.
                   Each line is a name and initiative separated by a
                   comma.

  -r <room id>     Room ID from rolz.org
                   e.g.: 12345678
EOF
exit 2
}

while getopts "h?f:r:" opt; do
    case "$opt" in
    f)
        FILE=$OPTARG;
        ;;
    r)
        ROOM_ID=$OPTARG;
        ;;
    h|\?)
        show_help
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

# Process command file
if [ -n "${FILE}" ]; then
    while read -ra char; do
        modifier=${char[1]}
        Init[${char[0]}]=$(curl -s "https://rolz.org/api/?d20+${modifier##+([[:space:]])}.json" | ${JQ_CMD} .result)
    done < ${FILE}
fi

# Add in any command line extras
i=1
while (( $# > $i )); do
    name=${!i}
    ((i++))
    adjust=${!i}
    ((i++))
    Init[${name}]=$(curl -s "https://rolz.org/api/?d20+${adjust}.json" | ${JQ_CMD} .result)
done

message=$(printf "red: Initiative($(date +"%H:%M")) : "; for k in "${!Init[@]}"; do
    echo "$k:  ${Init["$k"]}, "
done | sort -rn -k2 | tr '\n' ' ')

result=$(curl -s "https://rolz.org/api/post?room=${ROOM_ID}&text=${message}" | ${JQ_CMD} -r .content.room_id)

if [ $? = 0 ] && [ ${result} = ${ROOM_ID} ];then
    echo "finished"
else
    echo "failed"
fi
