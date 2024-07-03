.PHONY: check-ready check-live

host ?= localhost
max_try ?= 1
wait_seconds ?= 1
delay_seconds ?= 0
command = curl -s -o /dev/null -w '%{http_code}' -u admin:$$ADMIN_PASSWORD ${host}:5601/api/status | grep -q 200
service = Opensearch-Dashboards

default: check-ready

check-ready:
	wait_for "$(command)" $(service) $(host) $(max_try) $(wait_seconds) $(delay_seconds)

check-live:
	@echo "OK"
