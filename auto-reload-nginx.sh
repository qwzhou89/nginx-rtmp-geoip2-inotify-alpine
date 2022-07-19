# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

exec 1>/tmp/reload.log
exec 2>/dev/reload.log

WATCH_FOLDER="${WATCH_FOLDER:-/etc/nginx/conf.d}"

# Abort, if already running.
if [[ -n "$(ps | grep inotifywait | grep -v grep)" ]]; then
	echo "Already watching directory: ${WATCH_FOLDER}" >&2
	exit 1
fi

# Watch the directory( or file). When changes are detected,reload Nginx.
echo "Watching directory: ${WATCH_FOLDER}"
inotifywait \
	--event close_write \
    --timefmt '%d/%m/%y %H:%M' \
	--format "%T %e %w%f" \
	--monitor \
	--quiet \
	"${WATCH_FOLDER}" |
while read CHANGED
do
	echo "$CHANGED"@`date`
    nginx -s reload
done
