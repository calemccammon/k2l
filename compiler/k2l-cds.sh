# AppCDS: the JVM writes a class-data archive at the exit of the first full run and maps it on later ones.
# One archive per installation, in the user's cache directory; skipped when that is not writable, for
# --version/--help (which would archive almost nothing) and when K2L_NO_CDS is set.
k2l_cds=1
for k2l_arg in "$@"; do
    case $k2l_arg in --version|-h|--help) k2l_cds= ;; esac
done
k2l_cds_dir=${K2L_CDS_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/k2l}
if [ -n "$k2l_cds" ] && [ -z "$K2L_NO_CDS" ] && mkdir -p "$k2l_cds_dir" 2>/dev/null && [ -w "$k2l_cds_dir" ]; then
    k2l_cds_id=$(printf '%s' "$APP_HOME" | cksum | cut -d' ' -f1)
    DEFAULT_JVM_OPTS="$DEFAULT_JVM_OPTS \"-XX:+AutoCreateSharedArchive\" \"-XX:SharedArchiveFile=$k2l_cds_dir/k2l-$k2l_cds_id.jsa\" \"-Xlog:disable\""
fi
