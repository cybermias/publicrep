#!/bin/bash
#
# Version    | 1.0
# Email      | support@pfelk.com
# Website    | https://pfelk.com
#
###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                           Color Codes                                                                                           #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################
#
RESET='\033[0m'
WHITE_R='\033[39m'
RED='\033[1;31m' # Light Red.
GREEN='\033[1;32m' # Light Green.
#
header() {
  clear
  clear
  echo -e "${GREEN}#####################################################################################################${RESET}\\n"
}

header_red() {
  clear
  clear
  echo -e "${RED}#####################################################################################################${RESET}\\n"
}
#
# Check for root (sudo)
if [[ "$EUID" -ne 0 ]]; then
  header_red
  echo -e "${WHITE_R}#${RESET} The script need to be run as root...\\n\\n"
  echo -e "${WHITE_R}#${RESET} For Ubuntu based systems run the command below to login as root"
  echo -e "${GREEN}#${RESET} sudo -i\\n"
  echo -e "${WHITE_R}#${RESET} For Debian based systems run the command below to login as root"
  echo -e "${GREEN}#${RESET} su\\n\\n"
  exit 1
fi
#
###################################################################################################################################################################################################
#                                                                                                                                                                                                 #
#                                                                                   pfELK - Install Required Templates                                                                            #
#                                                                                                                                                                                                 #
###################################################################################################################################################################################################
curl -X PUT "localhost:9200/_component_template/pfelk-settings?pretty" -H 'Content-Type: application/json' -d'
{
  "version": 8,
  "template": {
    "settings": {
      "index": {
        "mapping": {
          "total_fields": {
            "limit": "10000"
          }
        },
        "refresh_interval": "5s"
      }
    },
    "mappings": {
      "_routing": {
        "required": false
      },
      "numeric_detection": false,
      "dynamic_date_formats": [
        "strict_date_optional_time",
        "yyyy/MM/dd HH:mm:ss Z||yyyy/MM/dd Z",
        "dd/MMM/yyyy:HH:mm:ss.SSS"
      ],
      "dynamic": true,
      "_source": {
        "excludes": [],
        "includes": [],
        "enabled": true
      },
      "dynamic_templates": [],
      "date_detection": true
    }
  },
  "_meta": {
    "description": "default settings for the pfelk indexes installed by pfelk",
    "managed": true
  }
}
'
curl -X PUT "localhost:9200/_component_template/pfelk-mappings-ecs?pretty" -H 'Content-Type: application/json' -d'
{
  "version": 8,
  "template": {
	"settings": {
	  "index": {
		"mapping": {
		  "total_fields": {
			"limit": "10000"
		  }
		},
		"refresh_interval": "5s"
	  }
	},
	"mappings": {
	  "_routing": {
		"required": false
	  },
	  "numeric_detection": false,
	  "_meta": {
		"version": "2.0.0-dev"
	  },
	  "_source": {
		"excludes": [],
		"includes": [],
		"enabled": true
	  },
	  "dynamic": true,
	  "dynamic_templates": [
		{
		  "strings_as_keyword": {
			"mapping": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"match_mapping_type": "string"
		  }
		}
	  ],
	  "date_detection": false,
	  "properties": {
		"container": {
		  "type": "object",
		  "properties": {
			"image": {
			  "type": "object",
			  "properties": {
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"tag": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"name": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"runtime": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"labels": {
			  "type": "object"
			}
		  }
		},
		"server": {
		  "type": "object",
		  "properties": {
			"nat": {
			  "type": "object",
			  "properties": {
				"port": {
				  "type": "long"
				},
				"ip": {
				  "type": "ip"
				}
			  }
			},
			"address": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"top_level_domain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"ip": {
			  "type": "ip"
			},
			"mac": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"packets": {
			  "type": "long"
			},
			"geo": {
			  "type": "object",
			  "properties": {
				"continent_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"region_iso_code": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"city_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"country_iso_code": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"country_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"location": {
				  "type": "geo_point"
				},
				"region_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"as": {
			  "type": "object",
			  "properties": {
				"number": {
				  "type": "long"
				},
				"organization": {
				  "type": "object",
				  "properties": {
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword",
					  "fields": {
						"text": {
						  "norms": false,
						  "type": "text"
						}
					  }
					}
				  }
				}
			  }
			},
			"registered_domain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"port": {
			  "type": "long"
			},
			"bytes": {
			  "type": "long"
			},
			"domain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"subdomain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"user": {
			  "type": "object",
			  "properties": {
				"full_name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"domain": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"roles": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"id": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"email": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"hash": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"group": {
				  "type": "object",
				  "properties": {
					"domain": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"id": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				}
			  }
			}
		  }
		},
		"agent": {
		  "type": "object",
		  "properties": {
			"build": {
			  "type": "object",
			  "properties": {
				"original": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"name": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"ephemeral_id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"type": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"version": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"log": {
		  "type": "object",
		  "properties": {
			"file": {
			  "type": "object",
			  "properties": {
				"path": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"original": {
			  "ignore_above": 1024,
			  "index": false,
			  "type": "keyword",
			  "doc_values": false
			},
			"level": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"logger": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"origin": {
			  "type": "object",
			  "properties": {
				"file": {
				  "type": "object",
				  "properties": {
					"line": {
					  "type": "integer"
					},
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				},
				"function": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"syslog": {
			  "type": "object",
			  "properties": {
				"severity": {
				  "type": "object",
				  "properties": {
					"code": {
					  "type": "long"
					},
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				},
				"priority": {
				  "type": "long"
				},
				"facility": {
				  "type": "object",
				  "properties": {
					"code": {
					  "type": "long"
					},
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				}
			  }
			}
		  }
		},
		"destination": {
		  "type": "object",
		  "properties": {
			"nat": {
			  "type": "object",
			  "properties": {
				"port": {
				  "type": "long"
				},
				"ip": {
				  "type": "ip"
				}
			  }
			},
			"address": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"top_level_domain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"ip": {
			  "type": "ip"
			},
			"mac": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"packets": {
			  "type": "long"
			},
			"geo": {
			  "type": "object",
			  "properties": {
				"continent_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"region_iso_code": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"city_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"country_iso_code": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"country_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"location": {
				  "type": "geo_point"
				},
				"region_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"as": {
			  "type": "object",
			  "properties": {
				"number": {
				  "type": "long"
				},
				"organization": {
				  "type": "object",
				  "properties": {
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword",
					  "fields": {
						"text": {
						  "norms": false,
						  "type": "text"
						}
					  }
					}
				  }
				}
			  }
			},
			"registered_domain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"port": {
			  "type": "long"
			},
			"bytes": {
			  "type": "long"
			},
			"domain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"subdomain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"user": {
			  "type": "object",
			  "properties": {
				"full_name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"domain": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"roles": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"id": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"email": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"hash": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"group": {
				  "type": "object",
				  "properties": {
					"domain": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"id": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				}
			  }
			}
		  }
		},
		"rule": {
		  "type": "object",
		  "properties": {
			"reference": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"license": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"author": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"name": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"ruleset": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"description": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"category": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"uuid": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"version": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"source": {
		  "type": "object",
		  "properties": {
			"nat": {
			  "type": "object",
			  "properties": {
				"port": {
				  "type": "long"
				},
				"ip": {
				  "type": "ip"
				}
			  }
			},
			"address": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"top_level_domain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"ip": {
			  "type": "ip"
			},
			"mac": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"packets": {
			  "type": "long"
			},
			"geo": {
			  "type": "object",
			  "properties": {
				"continent_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"region_iso_code": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"city_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"country_iso_code": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"country_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"location": {
				  "type": "geo_point"
				},
				"region_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"as": {
			  "type": "object",
			  "properties": {
				"number": {
				  "type": "long"
				},
				"organization": {
				  "type": "object",
				  "properties": {
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword",
					  "fields": {
						"text": {
						  "norms": false,
						  "type": "text"
						}
					  }
					}
				  }
				}
			  }
			},
			"registered_domain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"port": {
			  "type": "long"
			},
			"bytes": {
			  "type": "long"
			},
			"domain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"subdomain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"user": {
			  "type": "object",
			  "properties": {
				"full_name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"domain": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"roles": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"id": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"email": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"hash": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"group": {
				  "type": "object",
				  "properties": {
					"domain": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"id": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				}
			  }
			}
		  }
		},
		"error": {
		  "type": "object",
		  "properties": {
			"code": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"stack_trace": {
			  "ignore_above": 1024,
			  "index": false,
			  "type": "keyword",
			  "fields": {
				"text": {
				  "norms": false,
				  "type": "text"
				}
			  },
			  "doc_values": false
			},
			"message": {
			  "norms": false,
			  "type": "text"
			},
			"type": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"interface": {
		  "type": "object",
		  "properties": {
			"name": {
			  "type": "keyword"
			},
			"alias": {
			  "type": "keyword"
			},
			"id": {
			  "type": "keyword"
			}
		  }
		},
		"network": {
		  "type": "object",
		  "properties": {
			"transport": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"type": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"inner": {
			  "type": "object",
			  "properties": {
				"vlan": {
				  "type": "object",
				  "properties": {
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"id": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				}
			  }
			},
			"packets": {
			  "type": "long"
			},
			"community_id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"forwarded_ip": {
			  "type": "ip"
			},
			"protocol": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"application": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"vlan": {
			  "type": "object",
			  "properties": {
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"id": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"bytes": {
			  "type": "long"
			},
			"name": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"iana_number": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"direction": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"cloud": {
		  "type": "object",
		  "properties": {
			"availability_zone": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"instance": {
			  "type": "object",
			  "properties": {
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"id": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"provider": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"machine": {
			  "type": "object",
			  "properties": {
				"type": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"project": {
			  "type": "object",
			  "properties": {
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"id": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"region": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"account": {
			  "type": "object",
			  "properties": {
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"id": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			}
		  }
		},
		"observer": {
		  "type": "object",
		  "properties": {
			"product": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"os": {
			  "type": "object",
			  "properties": {
				"kernel": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"family": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"type": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"version": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"platform": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"full": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				}
			  }
			},
			"ip": {
			  "type": "ip"
			},
			"serial_number": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"type": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"version": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"mac": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"egress": {
			  "type": "object",
			  "properties": {
				"vlan": {
				  "type": "object",
				  "properties": {
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"id": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				},
				"zone": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"interface": {
				  "type": "object",
				  "properties": {
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"alias": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"id": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				}
			  }
			},
			"geo": {
			  "type": "object",
			  "properties": {
				"continent_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"region_iso_code": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"city_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"country_iso_code": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"country_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"location": {
				  "type": "geo_point"
				},
				"region_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"ingress": {
			  "type": "object",
			  "properties": {
				"vlan": {
				  "type": "object",
				  "properties": {
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"id": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				},
				"zone": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"interface": {
				  "type": "object",
				  "properties": {
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"alias": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"id": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				}
			  }
			},
			"hostname": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"vendor": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"name": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"trace": {
		  "type": "object",
		  "properties": {
			"id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"file": {
		  "type": "object",
		  "properties": {
			"extension": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"gid": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"drive_letter": {
			  "ignore_above": 1,
			  "type": "keyword"
			},
			"accessed": {
			  "type": "date"
			},
			"mtime": {
			  "type": "date"
			},
			"type": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"directory": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"inode": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"mode": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"path": {
			  "ignore_above": 1024,
			  "type": "keyword",
			  "fields": {
				"text": {
				  "norms": false,
				  "type": "text"
				}
			  }
			},
			"uid": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"code_signature": {
			  "type": "object",
			  "properties": {
				"valid": {
				  "type": "boolean"
				},
				"trusted": {
				  "type": "boolean"
				},
				"subject_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"exists": {
				  "type": "boolean"
				},
				"status": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"ctime": {
			  "type": "date"
			},
			"group": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"owner": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"created": {
			  "type": "date"
			},
			"target_path": {
			  "ignore_above": 1024,
			  "type": "keyword",
			  "fields": {
				"text": {
				  "norms": false,
				  "type": "text"
				}
			  }
			},
			"x509": {
			  "type": "object",
			  "properties": {
				"not_after": {
				  "type": "date"
				},
				"public_key_exponent": {
				  "index": false,
				  "type": "long",
				  "doc_values": false
				},
				"not_before": {
				  "type": "date"
				},
				"subject": {
				  "type": "object",
				  "properties": {
					"country": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"state_or_province": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"organization": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"distinguished_name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"locality": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"common_name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"organizational_unit": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				},
				"public_key_algorithm": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"public_key_curve": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"signature_algorithm": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"public_key_size": {
				  "type": "long"
				},
				"serial_number": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"version_number": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"alternative_names": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"issuer": {
				  "type": "object",
				  "properties": {
					"country": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"state_or_province": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"organization": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"distinguished_name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"locality": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"common_name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"organizational_unit": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				}
			  }
			},
			"size": {
			  "type": "long"
			},
			"mime_type": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"pe": {
			  "type": "object",
			  "properties": {
				"file_version": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"product": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"imphash": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"description": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"company": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"original_file_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"architecture": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"name": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"attributes": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"device": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"hash": {
			  "type": "object",
			  "properties": {
				"sha1": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"sha256": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"sha512": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"md5": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			}
		  }
		},
		"ecs": {
		  "type": "object",
		  "properties": {
			"version": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"related": {
		  "type": "object",
		  "properties": {
			"hosts": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"ip": {
			  "type": "ip"
			},
			"user": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"hash": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"host": {
		  "type": "object",
		  "properties": {
			"geo": {
			  "type": "object",
			  "properties": {
				"continent_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"region_iso_code": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"city_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"country_iso_code": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"country_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"location": {
				  "type": "geo_point"
				},
				"region_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"hostname": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"os": {
			  "type": "object",
			  "properties": {
				"kernel": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"family": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"type": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"version": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"platform": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"full": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				}
			  }
			},
			"domain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"ip": {
			  "type": "ip"
			},
			"name": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"type": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"user": {
			  "type": "object",
			  "properties": {
				"full_name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"domain": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"roles": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"id": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"email": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"hash": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"group": {
				  "type": "object",
				  "properties": {
					"domain": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"id": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				}
			  }
			},
			"mac": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"architecture": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"uptime": {
			  "type": "long"
			}
		  }
		},
		"client": {
		  "type": "object",
		  "properties": {
			"nat": {
			  "type": "object",
			  "properties": {
				"port": {
				  "type": "long"
				},
				"ip": {
				  "type": "ip"
				}
			  }
			},
			"address": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"top_level_domain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"ip": {
			  "type": "ip"
			},
			"mac": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"packets": {
			  "type": "long"
			},
			"geo": {
			  "type": "object",
			  "properties": {
				"continent_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"region_iso_code": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"city_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"country_iso_code": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"country_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"location": {
				  "type": "geo_point"
				},
				"region_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"as": {
			  "type": "object",
			  "properties": {
				"number": {
				  "type": "long"
				},
				"organization": {
				  "type": "object",
				  "properties": {
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword",
					  "fields": {
						"text": {
						  "norms": false,
						  "type": "text"
						}
					  }
					}
				  }
				}
			  }
			},
			"registered_domain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"port": {
			  "type": "long"
			},
			"bytes": {
			  "type": "long"
			},
			"domain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"subdomain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"user": {
			  "type": "object",
			  "properties": {
				"full_name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"domain": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"roles": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"id": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"email": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"hash": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"group": {
				  "type": "object",
				  "properties": {
					"domain": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"id": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				}
			  }
			}
		  }
		},
		"event": {
		  "type": "object",
		  "properties": {
			"reason": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"code": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"timezone": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"type": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"duration": {
			  "type": "long"
			},
			"reference": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"ingested": {
			  "type": "date"
			},
			"provider": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"action": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"end": {
			  "type": "date"
			},
			"id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"outcome": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"severity": {
			  "type": "long"
			},
			"original": {
			  "ignore_above": 1024,
			  "index": false,
			  "type": "keyword",
			  "doc_values": false
			},
			"risk_score": {
			  "type": "float"
			},
			"created": {
			  "format": "strict_date_optional_time||epoch_millis||MMM d HH:mm:ss||MMM dd HH:mm:ss",
			  "index": true,
			  "ignore_malformed": false,
			  "store": false,
			  "type": "date",
			  "doc_values": true
			},
			"kind": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"module": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"start": {
			  "type": "date"
			},
			"url": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"sequence": {
			  "type": "long"
			},
			"risk_score_norm": {
			  "type": "float"
			},
			"category": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"dataset": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"hash": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"user_agent": {
		  "type": "object",
		  "properties": {
			"original": {
			  "ignore_above": 1024,
			  "type": "keyword",
			  "fields": {
				"text": {
				  "norms": false,
				  "type": "text"
				}
			  }
			},
			"os": {
			  "type": "object",
			  "properties": {
				"kernel": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"family": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"type": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"version": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"platform": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"full": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				}
			  }
			},
			"name": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"device": {
			  "type": "object",
			  "properties": {
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"version": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"group": {
		  "type": "object",
		  "properties": {
			"domain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"name": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"registry": {
		  "type": "object",
		  "properties": {
			"hive": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"path": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"data": {
			  "type": "object",
			  "properties": {
				"strings": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"bytes": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"type": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"value": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"key": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"process": {
		  "type": "object",
		  "properties": {
			"parent": {
			  "type": "object",
			  "properties": {
				"pgid": {
				  "type": "long"
				},
				"start": {
				  "type": "date"
				},
				"pid": {
				  "type": "long"
				},
				"working_directory": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"thread": {
				  "type": "object",
				  "properties": {
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"id": {
					  "type": "long"
					}
				  }
				},
				"entity_id": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"title": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"executable": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"ppid": {
				  "type": "long"
				},
				"uptime": {
				  "type": "long"
				},
				"args": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"code_signature": {
				  "type": "object",
				  "properties": {
					"valid": {
					  "type": "boolean"
					},
					"trusted": {
					  "type": "boolean"
					},
					"subject_name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"exists": {
					  "type": "boolean"
					},
					"status": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				},
				"pe": {
				  "type": "object",
				  "properties": {
					"file_version": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"product": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"imphash": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"description": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"company": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"original_file_name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"architecture": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				},
				"exit_code": {
				  "type": "long"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"args_count": {
				  "type": "long"
				},
				"command_line": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"hash": {
				  "type": "object",
				  "properties": {
					"sha1": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"sha256": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"sha512": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"md5": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				}
			  }
			},
			"pgid": {
			  "type": "long"
			},
			"start": {
			  "type": "date"
			},
			"pid": {
			  "type": "long"
			},
			"working_directory": {
			  "ignore_above": 1024,
			  "type": "keyword",
			  "fields": {
				"text": {
				  "norms": false,
				  "type": "text"
				}
			  }
			},
			"thread": {
			  "type": "object",
			  "properties": {
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"id": {
				  "type": "long"
				}
			  }
			},
			"entity_id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"title": {
			  "ignore_above": 1024,
			  "type": "keyword",
			  "fields": {
				"text": {
				  "norms": false,
				  "type": "text"
				}
			  }
			},
			"executable": {
			  "ignore_above": 1024,
			  "type": "keyword",
			  "fields": {
				"text": {
				  "norms": false,
				  "type": "text"
				}
			  }
			},
			"ppid": {
			  "type": "long"
			},
			"uptime": {
			  "type": "long"
			},
			"args": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"code_signature": {
			  "type": "object",
			  "properties": {
				"valid": {
				  "type": "boolean"
				},
				"trusted": {
				  "type": "boolean"
				},
				"subject_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"exists": {
				  "type": "boolean"
				},
				"status": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"pe": {
			  "type": "object",
			  "properties": {
				"file_version": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"product": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"imphash": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"description": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"company": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"original_file_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"architecture": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"exit_code": {
			  "type": "long"
			},
			"name": {
			  "ignore_above": 1024,
			  "type": "keyword",
			  "fields": {
				"text": {
				  "norms": false,
				  "type": "text"
				}
			  }
			},
			"args_count": {
			  "type": "long"
			},
			"command_line": {
			  "ignore_above": 1024,
			  "type": "keyword",
			  "fields": {
				"text": {
				  "norms": false,
				  "type": "text"
				}
			  }
			},
			"hash": {
			  "type": "object",
			  "properties": {
				"sha1": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"sha256": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"sha512": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"md5": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			}
		  }
		},
		"package": {
		  "type": "object",
		  "properties": {
			"installed": {
			  "type": "date"
			},
			"build_version": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"description": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"type": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"version": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"reference": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"license": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"path": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"install_scope": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"size": {
			  "type": "long"
			},
			"checksum": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"name": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"architecture": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"dll": {
		  "type": "object",
		  "properties": {
			"path": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"code_signature": {
			  "type": "object",
			  "properties": {
				"valid": {
				  "type": "boolean"
				},
				"trusted": {
				  "type": "boolean"
				},
				"subject_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"exists": {
				  "type": "boolean"
				},
				"status": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"pe": {
			  "type": "object",
			  "properties": {
				"file_version": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"product": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"imphash": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"description": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"company": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"original_file_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"architecture": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"name": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"hash": {
			  "type": "object",
			  "properties": {
				"sha1": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"sha256": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"sha512": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"md5": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			}
		  }
		},
		"dns": {
		  "type": "object",
		  "properties": {
			"op_code": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"resolved_ip": {
			  "type": "ip"
			},
			"response_code": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"question": {
			  "type": "object",
			  "properties": {
				"registered_domain": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"top_level_domain": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"subdomain": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"type": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"class": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"answers": {
			  "type": "object",
			  "properties": {
				"data": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"type": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"class": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"ttl": {
				  "type": "long"
				}
			  }
			},
			"header_flags": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"type": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"vulnerability": {
		  "type": "object",
		  "properties": {
			"reference": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"severity": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"score": {
			  "type": "object",
			  "properties": {
				"environmental": {
				  "type": "float"
				},
				"version": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"temporal": {
				  "type": "float"
				},
				"base": {
				  "type": "float"
				}
			  }
			},
			"report_id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"scanner": {
			  "type": "object",
			  "properties": {
				"vendor": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"description": {
			  "ignore_above": 1024,
			  "type": "keyword",
			  "fields": {
				"text": {
				  "norms": false,
				  "type": "text"
				}
			  }
			},
			"id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"category": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"classification": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"enumeration": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"message": {
		  "norms": false,
		  "type": "text"
		},
		"url": {
		  "type": "object",
		  "properties": {
			"extension": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"original": {
			  "ignore_above": 1024,
			  "type": "keyword",
			  "fields": {
				"text": {
				  "norms": false,
				  "type": "text"
				}
			  }
			},
			"scheme": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"top_level_domain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"query": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"path": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"fragment": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"password": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"registered_domain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"port": {
			  "type": "long"
			},
			"domain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"subdomain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"full": {
			  "ignore_above": 1024,
			  "type": "keyword",
			  "fields": {
				"text": {
				  "norms": false,
				  "type": "text"
				}
			  }
			},
			"username": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"labels": {
		  "type": "object"
		},
		"tags": {
		  "ignore_above": 1024,
		  "type": "keyword"
		},
		"@timestamp": {
		  "type": "date"
		},
		"service": {
		  "type": "object",
		  "properties": {
			"node": {
			  "type": "object",
			  "properties": {
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"name": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"state": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"ephemeral_id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"type": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"version": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"organization": {
		  "type": "object",
		  "properties": {
			"name": {
			  "ignore_above": 1024,
			  "type": "keyword",
			  "fields": {
				"text": {
				  "norms": false,
				  "type": "text"
				}
			  }
			},
			"id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"http": {
		  "type": "object",
		  "properties": {
			"request": {
			  "type": "object",
			  "properties": {
				"referrer": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"method": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"mime_type": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"bytes": {
				  "type": "long"
				},
				"body": {
				  "type": "object",
				  "properties": {
					"bytes": {
					  "type": "long"
					},
					"content": {
					  "ignore_above": 1024,
					  "type": "keyword",
					  "fields": {
						"text": {
						  "norms": false,
						  "type": "text"
						}
					  }
					}
				  }
				}
			  }
			},
			"response": {
			  "type": "object",
			  "properties": {
				"status_code": {
				  "type": "long"
				},
				"mime_type": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"bytes": {
				  "type": "long"
				},
				"body": {
				  "type": "object",
				  "properties": {
					"bytes": {
					  "type": "long"
					},
					"content": {
					  "ignore_above": 1024,
					  "type": "keyword",
					  "fields": {
						"text": {
						  "norms": false,
						  "type": "text"
						}
					  }
					}
				  }
				}
			  }
			},
			"version": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"tls": {
		  "type": "object",
		  "properties": {
			"cipher": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"established": {
			  "type": "boolean"
			},
			"server": {
			  "type": "object",
			  "properties": {
				"not_after": {
				  "type": "date"
				},
				"x509": {
				  "type": "object",
				  "properties": {
					"not_after": {
					  "type": "date"
					},
					"public_key_exponent": {
					  "index": false,
					  "type": "long",
					  "doc_values": false
					},
					"not_before": {
					  "type": "date"
					},
					"subject": {
					  "type": "object",
					  "properties": {
						"country": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"state_or_province": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"organization": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"distinguished_name": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"locality": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"common_name": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"organizational_unit": {
						  "ignore_above": 1024,
						  "type": "keyword"
						}
					  }
					},
					"public_key_algorithm": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"public_key_curve": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"signature_algorithm": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"public_key_size": {
					  "type": "long"
					},
					"serial_number": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"version_number": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"alternative_names": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"issuer": {
					  "type": "object",
					  "properties": {
						"country": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"state_or_province": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"organization": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"distinguished_name": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"locality": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"common_name": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"organizational_unit": {
						  "ignore_above": 1024,
						  "type": "keyword"
						}
					  }
					}
				  }
				},
				"ja3s": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"not_before": {
				  "type": "date"
				},
				"subject": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"certificate": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"certificate_chain": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"hash": {
				  "type": "object",
				  "properties": {
					"sha1": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"sha256": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"md5": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				},
				"issuer": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"curve": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"client": {
			  "type": "object",
			  "properties": {
				"not_after": {
				  "type": "date"
				},
				"server_name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"x509": {
				  "type": "object",
				  "properties": {
					"not_after": {
					  "type": "date"
					},
					"public_key_exponent": {
					  "index": false,
					  "type": "long",
					  "doc_values": false
					},
					"not_before": {
					  "type": "date"
					},
					"subject": {
					  "type": "object",
					  "properties": {
						"country": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"state_or_province": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"organization": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"distinguished_name": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"locality": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"common_name": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"organizational_unit": {
						  "ignore_above": 1024,
						  "type": "keyword"
						}
					  }
					},
					"public_key_algorithm": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"public_key_curve": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"signature_algorithm": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"public_key_size": {
					  "type": "long"
					},
					"serial_number": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"version_number": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"alternative_names": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"issuer": {
					  "type": "object",
					  "properties": {
						"country": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"state_or_province": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"organization": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"distinguished_name": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"locality": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"common_name": {
						  "ignore_above": 1024,
						  "type": "keyword"
						},
						"organizational_unit": {
						  "ignore_above": 1024,
						  "type": "keyword"
						}
					  }
					}
				  }
				},
				"not_before": {
				  "type": "date"
				},
				"subject": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"supported_ciphers": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"certificate": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"ja3": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"certificate_chain": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"hash": {
				  "type": "object",
				  "properties": {
					"sha1": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"sha256": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"md5": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				},
				"issuer": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"next_protocol": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"resumed": {
			  "type": "boolean"
			},
			"version": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"version_protocol": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"threat": {
		  "type": "object",
		  "properties": {
			"framework": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"technique": {
			  "type": "object",
			  "properties": {
				"reference": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"subtechnique": {
				  "type": "object",
				  "properties": {
					"reference": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword",
					  "fields": {
						"text": {
						  "norms": false,
						  "type": "text"
						}
					  }
					},
					"id": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				},
				"id": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"tactic": {
			  "type": "object",
			  "properties": {
				"reference": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"id": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			}
		  }
		},
		"user": {
		  "type": "object",
		  "properties": {
			"effective": {
			  "type": "object",
			  "properties": {
				"full_name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"domain": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"roles": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"id": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"email": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"hash": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"group": {
				  "type": "object",
				  "properties": {
					"domain": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"id": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				}
			  }
			},
			"full_name": {
			  "ignore_above": 1024,
			  "type": "keyword",
			  "fields": {
				"text": {
				  "norms": false,
				  "type": "text"
				}
			  }
			},
			"domain": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"roles": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"changes": {
			  "type": "object",
			  "properties": {
				"full_name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"domain": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"roles": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"id": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"email": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"hash": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"group": {
				  "type": "object",
				  "properties": {
					"domain": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"id": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				}
			  }
			},
			"name": {
			  "ignore_above": 1024,
			  "type": "keyword",
			  "fields": {
				"text": {
				  "norms": false,
				  "type": "text"
				}
			  }
			},
			"id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"email": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"hash": {
			  "ignore_above": 1024,
			  "type": "keyword"
			},
			"group": {
			  "type": "object",
			  "properties": {
				"domain": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"id": {
				  "ignore_above": 1024,
				  "type": "keyword"
				}
			  }
			},
			"target": {
			  "type": "object",
			  "properties": {
				"full_name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"domain": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"roles": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"name": {
				  "ignore_above": 1024,
				  "type": "keyword",
				  "fields": {
					"text": {
					  "norms": false,
					  "type": "text"
					}
				  }
				},
				"id": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"email": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"hash": {
				  "ignore_above": 1024,
				  "type": "keyword"
				},
				"group": {
				  "type": "object",
				  "properties": {
					"domain": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"name": {
					  "ignore_above": 1024,
					  "type": "keyword"
					},
					"id": {
					  "ignore_above": 1024,
					  "type": "keyword"
					}
				  }
				}
			  }
			}
		  }
		},
		"transaction": {
		  "type": "object",
		  "properties": {
			"id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		},
		"span": {
		  "type": "object",
		  "properties": {
			"id": {
			  "ignore_above": 1024,
			  "type": "keyword"
			}
		  }
		}
	  }
	}
  },
  "_meta": {
	"description": "ecs for the pfelk indexes installed by pfelk",
	"managed": true
  }
}
'
curl -X PUT "localhost:9200/_ilm/policy/pfelk-ilm?pretty" -H 'Content-Type: application/json' -d'
{
  "policy": {
	"phases": {
	  "hot": {
		"min_age": "0ms",
		"actions": {
		  "rollover": {
			"max_size": "5gb",
			"max_age": "90d"
		  },
		  "set_priority": {
			"priority": 10
		  }
		}
	  },
	  "warm": {
		"actions": {
		  "set_priority": {
			"priority": 50
		  }
		}
	  },
	  "cold": {
		"min_age": "180d",
		"actions": {}
	  },
	  "delete": {
		"min_age": "365d",
		"actions": {}
	  }
	}
  }
}
'
curl -X PUT "localhost:9200/_index_template/pfelk?pretty" -H 'Content-Type: application/json' -d'
{
  "version": 9,
  "priority": 10,
  "template": {
    "mappings": {
      "_routing": {
        "required": false
      },
      "numeric_detection": false,
      "dynamic_date_formats": [
        "strict_date_optional_time",
        "yyyy/MM/dd HH:mm:ss Z||yyyy/MM/dd Z"
      ],
      "_source": {
        "excludes": [],
        "includes": [],
        "enabled": true
      },
      "dynamic": true,
      "dynamic_templates": [],
      "date_detection": true,
      "properties": {
        "pf": {
          "type": "object",
          "properties": {
            "tcp": {
              "type": "object",
              "properties": {
                "sequence_number": {
                  "type": "long"
                },
                "data_length": {
                  "type": "integer"
                },
                "flags": {
                  "type": "keyword"
                },
                "options": {
                  "eager_global_ordinals": false,
                  "index_phrases": false,
                  "fielddata": false,
                  "norms": true,
                  "index": true,
                  "store": false,
                  "type": "text",
                  "fields": {
                    "keyword": {
                      "type": "keyword"
                    }
                  },
                  "index_options": "positions"
                },
                "window": {
                  "type": "integer"
                }
              }
            },
            "ipv4": {
              "type": "object",
              "properties": {
                "offset": {
                  "type": "integer"
                },
                "flags": {
                  "type": "keyword"
                },
                "tos": {
                  "type": "keyword"
                },
                "packet": {
                  "type": "object",
                  "properties": {
                    "id": {
                      "type": "integer"
                    }
                  }
                },
                "ttl": {
                  "type": "integer"
                }
              }
            },
            "transport": {
              "type": "object",
              "properties": {
                "data_length": {
                  "type": "integer"
                }
              }
            },
            "packet": {
              "type": "object",
              "properties": {
                "length": {
                  "type": "integer"
                }
              }
            }
          }
        }
      }
    }
  },
  "index_patterns": [
    "pfelk-firewall-*"
  ],
  "composed_of": [
    "pfelk-settings",
    "pfelk-mappings-ecs"
  ],
  "_meta": {
    "description": "default pfelk indexes installed by pfelk",
    "managed": true
  }
}
'
