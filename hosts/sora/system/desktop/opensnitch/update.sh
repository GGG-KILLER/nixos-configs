#! /usr/bin/env nix-shell
#! nix-shell -i bash -p curl gnused gawk
# shellcheck shell=bash

set -euo pipefail

function fetch {
    local url path rm_leading_ip prepend_ip convert_abp

    while [ $# -gt 0 ]; do
        local arg="$1"
        shift 1
        case "$arg" in
        --remove-leading-ip)
            rm_leading_ip=1
            ;;
        --prepend-ip)
            prepend_ip=1
            ;;
        --convert-abp)
            convert_abp=1
            ;;
        *)
            if [ -z "${url+nonempty}" ]; then
                url="$arg"
            elif [ -z "${path+nonempty}" ]; then
                path="$arg"
            else
                echo "invalid fetch usage: more than one positional argument provided." 1>&2
                return 1
            fi
            ;;
        esac
    done

    echo -n "Fetching list $path: "

    local etag="${path%.txt}.etag"
    curl -sLo "$path.tmp" "$url" --etag-save "$etag" --etag-compare "$etag"

    # Exit if etag hasn't changed.
    ! [ -f "$path.tmp" ] && echo "ok." && return

    if [ ${rm_leading_ip:-0} = 1 ]; then
        sed -i -E 's/^[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}[[:space:]]*//g' "$path.tmp"
    fi

    if [ ${prepend_ip:-0} = 1 ]; then
        sed -i -E 's/^([[:space:]]*[^#])/0.0.0.0 \1/g' "$path.tmp"
    fi

    if [ ${convert_abp:-0} = 1 ]; then
        gawk --optimize -i inplace \
            -- \
            '
            /^[[:space:]]*$/ || /^([[:space:]]*)#/ { # Empty line or properly commented line
                print
                next # Don'\''t do any further processing.
            }

            /^([[:space:]]*)!/ { # Found an ABP comment
                gsub(/^([[:space:]]*)!/, "\\1#") # Replace ! with #
                print
                next # Don'\''t do any further processing.
            }

            /^\|\|[^\/]+\^/ { # We can only handle patterns that act on domains
                gsub(/[.[\(*^$+?{|]/, "\\\\&") # Escape regex
                gsub(/^\\\|\\\|/, "^(|.*\\.)") # Replace domain start with regex that matches subdomains
                gsub(/\\\^$/, "$") # Replace "separator" match with end of host match
                print
                next
            }

            { # When all else fails, panic.
                print "Invalid line:", $0
                exit 1
            }
            ' \
            "$path.tmp"
    fi

    mv "$path.tmp" "$path"

    echo "updated."
}

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
pushd "$SCRIPT_DIR" >/dev/null

(
    # Suspicious
    fetch 'https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt' "reject/hosts/KADhosts.txt"
    fetch 'https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts' "reject/hosts/FadeMind-Spam.txt"
    fetch 'https://v.firebog.net/hosts/static/w3kbl.txt' --prepend-ip "reject/hosts/firebog-w3kbl.txt"

    # Ads & Tracking
    fetch 'https://adaway.org/hosts.txt' --remove-leading-ip --prepend-ip "reject/hosts/adaway.txt"
    fetch 'https://v.firebog.net/hosts/AdguardDNS.txt' --remove-leading-ip --prepend-ip "reject/hosts/AdguardDNS.txt"
    fetch 'https://raw.githubusercontent.com/LanikSJ/ubo-filters/main/filters/getadmiral-domains.txt' --convert-abp "reject/regex/LanikSJ-ubo-filters-getadmiral-domains.txt"
    fetch 'https://o0.pages.dev/Lite/hosts.txt' "reject/hosts/1hosts-lite.txt"
    fetch 'https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt' "reject/hosts/developerdan-ads-and-tracking.txt"
    fetch 'https://big.oisd.nl/regex' "reject/regex/oisd-regex.txt"

    # Malware
    fetch 'https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt' "reject/hosts/adfilt-malware.txt"
    fetch 'https://v.firebog.net/hosts/Prigent-Crypto.txt' --remove-leading-ip --prepend-ip "reject/hosts/firebog-Prigent-Crypto.txt"
    fetch 'https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts' "reject/hosts/FadeMind-Risk.txt"
    fetch 'https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt' \
        --prepend-ip \
        "reject/hosts/ethanr-dns-blacklists-Mandiant_APT1_Report_Appendix_D.txt"
    fetch 'https://phishing.army/download/phishing_army_blocklist_extended.txt' --prepend-ip "reject/hosts/phishing_army_blocklist_extended.txt"
    fetch 'https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt' --prepend-ip "reject/hosts/quidsup-notrack-blocklists-malware.txt"
    fetch 'https://v.firebog.net/hosts/RPiList-Malware.txt' --convert-abp "reject/regex/RPiList-Malware.txt"
    fetch 'https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt' --prepend-ip "reject/hosts/Spam404-main-blacklist.txt"
    fetch 'https://raw.githubusercontent.com/AssoEchap/stalkerware-indicators/master/generated/hosts' --prepend-ip "reject/hosts/stalkerware-indicators.txt"
    fetch 'https://urlhaus.abuse.ch/downloads/hostfile/' "reject/hosts/urlhaus.hosts.txt"
    fetch 'https://threatfox.abuse.ch/downloads/hostfile/' "reject/hosts/threatfox.hosts.txt"
    fetch 'https://lists.cyberhost.uk/malware.txt' --prepend-ip "reject/hosts/cyberhost-malware.txt"
) || :

popd >/dev/null
