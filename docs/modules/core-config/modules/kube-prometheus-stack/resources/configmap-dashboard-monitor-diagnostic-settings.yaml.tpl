apiVersion: v1
kind: ConfigMap
metadata:
  name: dashboard-monitor-diagnostic-settings
  labels:
    grafana_dashboard: "1"
  namespace: monitoring
data:
  monitor-diagnostic-settings.json: |-
    {
      "__inputs": [
        {
          "name": "DS_AZURE_MONITOR",
          "label": "Azure Monitor",
          "description": "",
          "type": "datasource",
          "pluginId": "grafana-azure-monitor-datasource",
          "pluginName": "Azure Monitor"
        }
      ],
      "__requires": [
        {
          "type": "grafana",
          "id": "grafana",
          "name": "Grafana",
          "version": "8.2.3"
        },
        {
          "type": "datasource",
          "id": "grafana-azure-monitor-datasource",
          "name": "Azure Monitor",
          "version": "0.3.0"
        },
        {
          "type": "panel",
          "id": "logs",
          "name": "Logs",
          "version": ""
        },
        {
          "type": "panel",
          "id": "stat",
          "name": "Stat",
          "version": ""
        },
        {
          "type": "panel",
          "id": "timeseries",
          "name": "Time series",
          "version": ""
        }
      ],
      "annotations": {
        "list": [
          {
            "builtIn": 1,
            "datasource": "-- Grafana --",
            "enable": true,
            "hide": true,
            "iconColor": "rgba(0, 211, 255, 1)",
            "name": "Annotations & Alerts",
            "target": {
              "limit": 100,
              "matchAny": false,
              "tags": [],
              "type": "dashboard"
            },
            "type": "dashboard"
          }
        ]
      },
      "editable": true,
      "fiscalYearStartMonth": 0,
      "gnetId": null,
      "graphTooltip": 0,
      "id": null,
      "iteration": 1638373887978,
      "links": [],
      "liveNow": false,
      "panels": [
        {
          "datasource": "Azure Monitor",
          "fieldConfig": {
            "defaults": {
              "color": {
                "fixedColor": "super-light-green",
                "mode": "fixed"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              }
            },
            "overrides": []
          },
          "gridPos": {
            "h": 4,
            "w": 6,
            "x": 0,
            "y": 0
          },
          "id": 12,
          "options": {
            "colorMode": "value",
            "graphMode": "none",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "text": {},
            "textMode": "auto"
          },
          "pluginVersion": "8.2.3",
          "targets": [
            {
              "appInsights": {
                "dimension": [],
                "metricName": "select",
                "timeGrain": "auto"
              },
              "azureLogAnalytics": {
                "query": "AzureDiagnostics\n| where $__timeFilter(TimeGenerated)\n| summarize count()",
                "resource": "$azureLogAnalytics_resource",
                "resultFormat": "time_series"
              },
              "azureMonitor": {
                "aggOptions": [],
                "dimensionFilter": "*",
                "dimensionFilters": [],
                "timeGrain": "auto",
                "timeGrains": [],
                "top": "10"
              },
              "azureResourceGraph": {
                "resultFormat": "table"
              },
              "insightsAnalytics": {
                "query": "",
                "resultFormat": "time_series"
              },
              "queryType": "Azure Log Analytics",
              "refId": "A",
              "subscription": "$subscription",
              "subscriptions": [
                "$subscription"
              ]
            }
          ],
          "title": "Total logs",
          "type": "stat"
        },
        {
          "datasource": "Azure Monitor",
          "fieldConfig": {
            "defaults": {
              "color": {
                "fixedColor": "super-light-yellow",
                "mode": "fixed"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              }
            },
            "overrides": []
          },
          "gridPos": {
            "h": 4,
            "w": 6,
            "x": 6,
            "y": 0
          },
          "id": 14,
          "options": {
            "colorMode": "value",
            "graphMode": "none",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "text": {},
            "textMode": "auto"
          },
          "pluginVersion": "8.2.3",
          "targets": [
            {
              "appInsights": {
                "dimension": [],
                "metricName": "select",
                "timeGrain": "auto"
              },
              "azureLogAnalytics": {
                "query": "AzureDiagnostics\n| where $__timeFilter(TimeGenerated)\n| where log_s startswith \"I\"\n| summarize count()",
                "resource": "$azureLogAnalytics_resource",
                "resultFormat": "time_series"
              },
              "azureMonitor": {
                "aggOptions": [],
                "dimensionFilter": "*",
                "dimensionFilters": [],
                "timeGrain": "auto",
                "timeGrains": [],
                "top": "10"
              },
              "azureResourceGraph": {
                "resultFormat": "table"
              },
              "insightsAnalytics": {
                "query": "",
                "resultFormat": "time_series"
              },
              "queryType": "Azure Log Analytics",
              "refId": "A",
              "subscription": "$subscription",
              "subscriptions": [
                "$subscription"
              ]
            }
          ],
          "title": "Total info",
          "type": "stat"
        },
        {
          "datasource": "Azure Monitor",
          "fieldConfig": {
            "defaults": {
              "color": {
                "fixedColor": "super-light-orange",
                "mode": "fixed"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              }
            },
            "overrides": []
          },
          "gridPos": {
            "h": 4,
            "w": 6,
            "x": 12,
            "y": 0
          },
          "id": 11,
          "options": {
            "colorMode": "value",
            "graphMode": "none",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "text": {},
            "textMode": "auto"
          },
          "pluginVersion": "8.2.3",
          "targets": [
            {
              "appInsights": {
                "dimension": [],
                "metricName": "select",
                "timeGrain": "auto"
              },
              "azureLogAnalytics": {
                "query": "AzureDiagnostics\n| where $__timeFilter(TimeGenerated)\n| where log_s startswith \"W\"\n| summarize count()",
                "resource": "$azureLogAnalytics_resource",
                "resultFormat": "time_series"
              },
              "azureMonitor": {
                "aggOptions": [],
                "dimensionFilter": "*",
                "dimensionFilters": [],
                "timeGrain": "auto",
                "timeGrains": [],
                "top": "10"
              },
              "azureResourceGraph": {
                "resultFormat": "table"
              },
              "insightsAnalytics": {
                "query": "",
                "resultFormat": "time_series"
              },
              "queryType": "Azure Log Analytics",
              "refId": "A",
              "subscription": "$subscription",
              "subscriptions": [
                "$subscription"
              ]
            }
          ],
          "title": "Total warnings",
          "type": "stat"
        },
        {
          "datasource": "Azure Monitor",
          "fieldConfig": {
            "defaults": {
              "color": {
                "fixedColor": "light-red",
                "mode": "fixed"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              }
            },
            "overrides": []
          },
          "gridPos": {
            "h": 4,
            "w": 6,
            "x": 18,
            "y": 0
          },
          "id": 13,
          "options": {
            "colorMode": "value",
            "graphMode": "none",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "text": {},
            "textMode": "auto"
          },
          "pluginVersion": "8.2.3",
          "targets": [
            {
              "appInsights": {
                "dimension": [],
                "metricName": "select",
                "timeGrain": "auto"
              },
              "azureLogAnalytics": {
                "query": "AzureDiagnostics\n| where $__timeFilter(TimeGenerated)\n| where log_s startswith \"E\"\n| summarize count()",
                "resource": "$azureLogAnalytics_resource",
                "resultFormat": "time_series"
              },
              "azureMonitor": {
                "aggOptions": [],
                "dimensionFilter": "*",
                "dimensionFilters": [],
                "timeGrain": "auto",
                "timeGrains": [],
                "top": "10"
              },
              "azureResourceGraph": {
                "resultFormat": "table"
              },
              "insightsAnalytics": {
                "query": "",
                "resultFormat": "time_series"
              },
              "queryType": "Azure Log Analytics",
              "refId": "A",
              "subscription": "$subscription",
              "subscriptions": [
                "$subscription"
              ]
            }
          ],
          "title": "Total errors",
          "type": "stat"
        },
        {
          "datasource": "Azure Monitor",
          "fieldConfig": {
            "defaults": {
              "color": {
                "fixedColor": "super-light-green",
                "mode": "fixed"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              }
            },
            "overrides": []
          },
          "gridPos": {
            "h": 4,
            "w": 6,
            "x": 0,
            "y": 4
          },
          "id": 15,
          "options": {
            "colorMode": "value",
            "graphMode": "none",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "text": {},
            "textMode": "auto"
          },
          "pluginVersion": "8.2.3",
          "targets": [
            {
              "appInsights": {
                "dimension": [],
                "metricName": "select",
                "timeGrain": "auto"
              },
              "azureLogAnalytics": {
                "query": "AzureDiagnostics\n| where $__timeFilter(TimeGenerated)\n| where Category has \"$category\"\n| summarize count()",
                "resource": "$azureLogAnalytics_resource",
                "resultFormat": "time_series"
              },
              "azureMonitor": {
                "aggOptions": [],
                "dimensionFilter": "*",
                "dimensionFilters": [],
                "timeGrain": "auto",
                "timeGrains": [],
                "top": "10"
              },
              "azureResourceGraph": {
                "resultFormat": "table"
              },
              "insightsAnalytics": {
                "query": "",
                "resultFormat": "time_series"
              },
              "queryType": "Azure Log Analytics",
              "refId": "A",
              "subscription": "$subscription",
              "subscriptions": [
                "$subscription"
              ]
            }
          ],
          "title": "Total logs for category",
          "type": "stat"
        },
        {
          "datasource": "Azure Monitor",
          "fieldConfig": {
            "defaults": {
              "color": {
                "fixedColor": "super-light-yellow",
                "mode": "fixed"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              }
            },
            "overrides": []
          },
          "gridPos": {
            "h": 4,
            "w": 6,
            "x": 6,
            "y": 4
          },
          "id": 16,
          "options": {
            "colorMode": "value",
            "graphMode": "none",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "text": {},
            "textMode": "auto"
          },
          "pluginVersion": "8.2.3",
          "targets": [
            {
              "appInsights": {
                "dimension": [],
                "metricName": "select",
                "timeGrain": "auto"
              },
              "azureLogAnalytics": {
                "query": "AzureDiagnostics\n| where $__timeFilter(TimeGenerated)\n| where log_s startswith \"I\"\n| where Category has \"$category\"\n| summarize count()",
                "resource": "$azureLogAnalytics_resource",
                "resultFormat": "time_series"
              },
              "azureMonitor": {
                "aggOptions": [],
                "dimensionFilter": "*",
                "dimensionFilters": [],
                "timeGrain": "auto",
                "timeGrains": [],
                "top": "10"
              },
              "azureResourceGraph": {
                "resultFormat": "table"
              },
              "insightsAnalytics": {
                "query": "",
                "resultFormat": "time_series"
              },
              "queryType": "Azure Log Analytics",
              "refId": "A",
              "subscription": "$subscription",
              "subscriptions": [
                "$subscription"
              ]
            }
          ],
          "title": "Total info for category",
          "type": "stat"
        },
        {
          "datasource": "Azure Monitor",
          "fieldConfig": {
            "defaults": {
              "color": {
                "fixedColor": "super-light-orange",
                "mode": "fixed"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              }
            },
            "overrides": []
          },
          "gridPos": {
            "h": 4,
            "w": 6,
            "x": 12,
            "y": 4
          },
          "id": 17,
          "options": {
            "colorMode": "value",
            "graphMode": "none",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "text": {},
            "textMode": "auto"
          },
          "pluginVersion": "8.2.3",
          "targets": [
            {
              "appInsights": {
                "dimension": [],
                "metricName": "select",
                "timeGrain": "auto"
              },
              "azureLogAnalytics": {
                "query": "AzureDiagnostics\n| where $__timeFilter(TimeGenerated)\n| where log_s startswith \"W\"\n| where Category has \"$category\"\n| summarize count()",
                "resource": "$azureLogAnalytics_resource",
                "resultFormat": "time_series"
              },
              "azureMonitor": {
                "aggOptions": [],
                "dimensionFilter": "*",
                "dimensionFilters": [],
                "timeGrain": "auto",
                "timeGrains": [],
                "top": "10"
              },
              "azureResourceGraph": {
                "resultFormat": "table"
              },
              "insightsAnalytics": {
                "query": "",
                "resultFormat": "time_series"
              },
              "queryType": "Azure Log Analytics",
              "refId": "A",
              "subscription": "$subscription",
              "subscriptions": [
                "$subscription"
              ]
            }
          ],
          "title": "Total warnings for category",
          "type": "stat"
        },
        {
          "datasource": "Azure Monitor",
          "fieldConfig": {
            "defaults": {
              "color": {
                "fixedColor": "light-red",
                "mode": "fixed"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              }
            },
            "overrides": []
          },
          "gridPos": {
            "h": 4,
            "w": 6,
            "x": 18,
            "y": 4
          },
          "id": 18,
          "options": {
            "colorMode": "value",
            "graphMode": "none",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "text": {},
            "textMode": "auto"
          },
          "pluginVersion": "8.2.3",
          "targets": [
            {
              "appInsights": {
                "dimension": [],
                "metricName": "select",
                "timeGrain": "auto"
              },
              "azureLogAnalytics": {
                "query": "AzureDiagnostics\n| where $__timeFilter(TimeGenerated)\n| where log_s startswith \"E\"\n| where Category has \"$category\"\n| summarize count()",
                "resource": "$azureLogAnalytics_resource",
                "resultFormat": "time_series"
              },
              "azureMonitor": {
                "aggOptions": [],
                "dimensionFilter": "*",
                "dimensionFilters": [],
                "timeGrain": "auto",
                "timeGrains": [],
                "top": "10"
              },
              "azureResourceGraph": {
                "resultFormat": "table"
              },
              "insightsAnalytics": {
                "query": "",
                "resultFormat": "time_series"
              },
              "queryType": "Azure Log Analytics",
              "refId": "A",
              "subscription": "$subscription",
              "subscriptions": [
                "$subscription"
              ]
            }
          ],
          "title": "Total errors for category",
          "type": "stat"
        },
        {
          "datasource": "Azure Monitor",
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "palette-classic"
              },
              "custom": {
                "axisLabel": "",
                "axisPlacement": "auto",
                "barAlignment": 0,
                "drawStyle": "line",
                "fillOpacity": 0,
                "gradientMode": "none",
                "hideFrom": {
                  "legend": false,
                  "tooltip": false,
                  "viz": false
                },
                "lineInterpolation": "linear",
                "lineWidth": 1,
                "pointSize": 5,
                "scaleDistribution": {
                  "type": "linear"
                },
                "showPoints": "auto",
                "spanNulls": false,
                "stacking": {
                  "group": "A",
                  "mode": "none"
                },
                "thresholdsStyle": {
                  "mode": "off"
                }
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              }
            },
            "overrides": []
          },
          "gridPos": {
            "h": 9,
            "w": 24,
            "x": 0,
            "y": 8
          },
          "id": 8,
          "options": {
            "legend": {
              "calcs": [],
              "displayMode": "list",
              "placement": "bottom"
            },
            "tooltip": {
              "mode": "single"
            }
          },
          "pluginVersion": "8.0.3",
          "targets": [
            {
              "appInsights": {
                "dimension": [],
                "metricName": "select",
                "timeGrain": "auto"
              },
              "azureLogAnalytics": {
                "query": "AzureDiagnostics\n| where $__timeFilter(TimeGenerated)\n| where log_s has \"$search\"\n| where Category has \"$category\"\n| summarize count() by Category, bin(TimeGenerated, 15m)\n| order by TimeGenerated asc",
                "resource": "$azureLogAnalytics_resource",
                "resultFormat": "time_series"
              },
              "azureMonitor": {
                "aggOptions": [],
                "dimensionFilter": "*",
                "dimensionFilters": [],
                "timeGrain": "auto",
                "timeGrains": [],
                "top": "10"
              },
              "azureResourceGraph": {
                "resultFormat": "table"
              },
              "insightsAnalytics": {
                "query": "",
                "resultFormat": "time_series"
              },
              "queryType": "Azure Log Analytics",
              "refId": "A",
              "subscription": "$subscription",
              "subscriptions": [
                "$subscription"
              ]
            }
          ],
          "title": "Total based on category and search term",
          "type": "timeseries"
        },
        {
          "datasource": "Azure Monitor",
          "description": "Test",
          "gridPos": {
            "h": 16,
            "w": 24,
            "x": 0,
            "y": 17
          },
          "id": 2,
          "options": {
            "dedupStrategy": "none",
            "enableLogDetails": true,
            "prettifyLogMessage": false,
            "showCommonLabels": false,
            "showLabels": false,
            "showTime": true,
            "sortOrder": "Descending",
            "wrapLogMessage": true
          },
          "targets": [
            {
              "appInsights": {
                "dimension": [],
                "metricName": "select",
                "timeGrain": "auto"
              },
              "azureLogAnalytics": {
                "query": "AzureDiagnostics                                                            //the table to query (e.g. Usage, Heartbeat, Perf)\n| where $__timeFilter()\n| project TimeGenerated, Category, stream_s, log_s, pod_s, Resource, ResourceGroup, SubscriptionId\n| where log_s has \"$search\"\n| where Category has \"$category\"\n| top 1000 by TimeGenerated desc",
                "resource": "$azureLogAnalytics_resource",
                "resultFormat": "table"
              },
              "azureMonitor": {
                "aggOptions": [],
                "dimensionFilter": "*",
                "dimensionFilters": [],
                "timeGrain": "auto",
                "timeGrains": [],
                "top": "10"
              },
              "azureResourceGraph": {
                "resultFormat": "table"
              },
              "hide": false,
              "insightsAnalytics": {
                "query": "",
                "resultFormat": "time_series"
              },
              "queryType": "Azure Log Analytics",
              "refId": "A",
              "subscription": "$subscription",
              "subscriptions": [
                "$subscription"
              ]
            }
          ],
          "title": "Log panel based on category and search term",
          "transformations": [
            {
              "id": "organize",
              "options": {
                "excludeByName": {
                  "TimeGenerated": false
                },
                "indexByName": {
                  "Category": 2,
                  "Resource": 5,
                  "TimeGenerated": 0,
                  "log_s": 1,
                  "pod_s": 4,
                  "stream_s": 3
                },
                "renameByName": {
                  "Category": "category",
                  "Resource": "cluster",
                  "TimeGenerated": "time",
                  "log_s": "message",
                  "pod_s": "pod",
                  "stream_s": "stream"
                }
              }
            }
          ],
          "transparent": true,
          "type": "logs"
        }
      ],
      "refresh": "",
      "schemaVersion": 31,
      "style": "dark",
      "tags": [
        "azure",
        "control-plane",
        "lnrs-platform"
      ],
      "templating": {
        "list": [
          {
            "current": {},
            "datasource": {
              "type": "grafana-azure-monitor-datasource",
              "uid": "$${datasource}"
            },
            "definition": "AzureDiagnostics\n| project Category",
            "hide": 0,
            "includeAll": false,
            "label": "category",
            "multi": false,
            "name": "category",
            "options": [],
            "query": {
              "azureLogAnalytics": {
                "query": "AzureDiagnostics\n| project Category",
                "resource": "$azureLogAnalytics_resource"
              },
              "queryType": "Azure Log Analytics",
              "refId": "A",
              "subscription": "${subscription_id}"
            },
            "refresh": 1,
            "regex": "",
            "skipUrlSync": false,
            "sort": 1,
            "type": "query"
          },
          {
            "current": {
              "selected": false,
              "text": "",
              "value": ""
            },
            "hide": 0,
            "name": "search",
            "options": [
              {
                "selected": true,
                "text": "error",
                "value": "error"
              }
            ],
            "query": "",
            "skipUrlSync": false,
            "type": "textbox"
          },
          {
            "description": "",
            "hide": 2,
            "label": "Azure Log Analytics Control Plane ID",
            "name": "azureLogAnalytics_resource",
            "query": "${resource_id}",
            "skipUrlSync": false,
            "type": "constant"
          },
          {
            "hide": 2,
            "label": "Subscription ID",
            "name": "subscription",
            "query": "${subscription_id}",
            "skipUrlSync": false,
            "type": "constant"
          },
          {
            "current": {
              "selected": false,
              "text": "Azure Monitor",
              "value": "Azure Monitor"
            },
            "hide": 2,
            "includeAll": false,
            "multi": false,
            "name": "datasource",
            "options": [],
            "query": "grafana-azure-monitor-datasource",
            "refresh": 1,
            "regex": "",
            "skipUrlSync": false,
            "type": "datasource"
          }
        ]
      },
      "time": {
        "from": "now-30m",
        "to": "now"
      },
      "timepicker": {},
      "timezone": "",
      "title": "AKS Control Plane Logs",
      "uid": "dDb1LgKnz",
      "version": 1
    }
