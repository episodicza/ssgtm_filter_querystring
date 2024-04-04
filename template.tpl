___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Filter Query String Parameters",
  "description": "Whitelist or Blacklist query parameters in a URL by key. Can be used to remove PII, tracking or redundant data from URLs before passing on to other services like GA4 or Meta.",
  "categories": [
    "UTILITY",
    "ATTRIBUTION"
  ],
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "urlSource",
    "displayName": "URL Source",
    "macrosInSelect": true,
    "selectItems": [
      {
        "value": "event_page_location",
        "displayValue": "page_location"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "event_page_location",
    "help": "Choose \u003cstrong\u003epage_location\u003c/strong\u003e to use the respective key from the Event Data object, or provide a variable that returns a valid URL string."
  },
  {
    "type": "RADIO",
    "name": "filterType",
    "displayName": "Filter Type",
    "radioItems": [
      {
        "value": "blacklist",
        "displayValue": "Blacklist"
      },
      {
        "value": "whitelist",
        "displayValue": "Whitelist"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "blacklist",
    "help": "\u003cb\u003eBlacklist\u003c/b\u003e will exclude all the parameters in the filter list. \u003cb\u003eWhitelist\u003c/b\u003e will include only the parameters in the filter list."
  },
  {
    "type": "SIMPLE_TABLE",
    "name": "filterParams",
    "displayName": "Filter Parameters",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "Name",
        "name": "name",
        "type": "TEXT",
        "isUnique": true,
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ]
      },
      {
        "defaultValue": false,
        "displayName": "Case Sensitive Match",
        "name": "caseSensitive",
        "type": "SELECT",
        "selectItems": [
          {
            "value": true,
            "displayValue": "True"
          },
          {
            "value": false,
            "displayValue": "False"
          }
        ],
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ]
      }
    ],
    "newRowButtonText": "Add query parameter",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "help": "The query string parameters to whitelist or blacklist.\u003cbr /\u003eCase sensitive matching will require the filter parameter to match the case of the URL query string parameters exactly."
  }
]


___SANDBOXED_JS_FOR_SERVER___

const getEventData = require('getEventData');
const parseUrl = require('parseUrl');
const decodeUriComponent = require('decodeUriComponent');
const log = require('logToConsole');

const url = data.urlSource === 'event_page_location' ? getEventData('page_location') : data.urlSource;
const parsedUrl = parseUrl(url);

if (!parsedUrl) return;
if (!parsedUrl.search) return url;

// We loop through this often so pre-transform filter keys for case sensitivity
data.filterParams.map(r => {
  if (!r.caseSensitive) r.name = r.name.toLowerCase();
  return r;
});

log(data.filterParams);

// Compare function used to match supplied filter params against search query keys
const cmp = (fp, qk) => fp.name === (fp.caseSensitive ? qk : qk.toLowerCase());

// Filter function used for Black/white list matching
var filter;
if (data.filterType === "whitelist") {
  filter = matcher => data.filterParams.some(matcher);
} else {
  filter = matcher => !data.filterParams.some(matcher);
}

let newSearch = [];
// .search will have a ? prefix
for (const pair of parsedUrl.search.split("?")[1].split("&")) {
  if (pair) {
    const key = decodeUriComponent(pair.split("=")[0]);    
    if (filter(fp => cmp(fp, key))) newSearch.push(pair);
  }
}
newSearch = newSearch.length ? "?" + newSearch.join("&") : "";

return parsedUrl.origin + parsedUrl.pathname + newSearch + parsedUrl.hash;


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "page_location"
              }
            ]
          }
        },
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: No Query String
  code: |-
    const mockData = {
      urlSource: "https://www.example.com:8080/path1/Path2.ext#target",
      filterType: "blacklist",
      filterParams: []
    };

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo("https://www.example.com:8080/path1/Path2.ext#target");
- name: Weird urlSource
  code: |
    let mockData = {
      urlSource: "",
      filterType: "blacklist",
      filterParams: []
    };
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(undefined);

    mockData = {
      urlSource: null,
      filterType: "blacklist",
      filterParams: []
    };
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(undefined);

    mockData = {
      urlSource: undefined,
      filterType: "blacklist",
      filterParams: []
    };
    variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo(undefined);
- name: Blacklist case insensitive match
  code: |
    var mockData = {
      urlSource: "https://www.example.com:8080?k1=v1&k2=v2&K3=v3",
      filterType: "blacklist",
      filterParams: [
        {name: "K2", caseSensitive: false},
        {name: "k3", caseSensitive: false}
      ]
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://www.example.com:8080/?k1=v1");
- name: Blacklist Case Sensitive Match
  code: |
    var mockData = {
      urlSource: "https://www.example.com:8080?K1=v1&k2=v2&K3=v3",
      filterType: "blacklist",
      filterParams: [
        {name: "k1", caseSensitive: true},
        {name: "K2", caseSensitive: true},
        {name: "K3", caseSensitive: true}
      ]
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://www.example.com:8080/?K1=v1&k2=v2");
- name: Whitelist Case Insensitive
  code: |
    var mockData = {
      urlSource: "https://www.example.com:8080?k1=v1&k2=v2&K3=v3",
      filterType: "whitelist",
      filterParams: [
        {name: "K2", caseSensitive: false},
        {name: "k3", caseSensitive: false}
      ]
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://www.example.com:8080/?k2=v2&K3=v3");
- name: Whitelist Case Sensitive
  code: |
    var mockData = {
      urlSource: "https://www.example.com:8080?k1=v1&k2=v2&K3=v3",
      filterType: "whitelist",
      filterParams: [
        {name: "k1", caseSensitive: true},
        {name: "K2", caseSensitive: true},
        {name: "K3", caseSensitive: true}
      ]
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://www.example.com:8080/?k1=v1&K3=v3");
- name: Whitelist removing everything
  code: |
    var mockData = {
      urlSource: "https://www.example.com:8080?k1=v1&k2=v2&K3=v3#target",
      filterType: "whitelist",
      filterParams: [
        {name: "nothing", caseSensitive: false}
      ]
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://www.example.com:8080/#target");
- name: Blacklist removing everything
  code: |
    var mockData = {
      urlSource: "https://www.example.com:8080?k1=v1#target",
      filterType: "blacklist",
      filterParams: [
        {name: "k1", caseSensitive: false}
      ]
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://www.example.com:8080/#target");
- name: Whitelist mixed case
  code: |
    var mockData = {
      urlSource: "https://www.example.com:8080?k1=v1&k2=v2&K3=v3",
      filterType: "whitelist",
      filterParams: [
        {name: "k1", caseSensitive: true},
        {name: "K2", caseSensitive: false}
      ]
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://www.example.com:8080/?k1=v1&k2=v2");
- name: Blacklist mixed case
  code: |
    var mockData = {
      urlSource: "https://www.example.com:8080?k1=v1&k2=v2&K3=v3",
      filterType: "blacklist",
      filterParams: [
        {name: "k1", caseSensitive: true},
        {name: "K2", caseSensitive: false}
      ]
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://www.example.com:8080/?K3=v3");
- name: Blacklist array keys
  code: |-
    var mockData = {
      urlSource: "https://www.example.com:8080?k1=v1&k1=v2&k3=v3",
      filterType: "blacklist",
      filterParams: [
        {name: "k1", caseSensitive: false}
      ]
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://www.example.com:8080/?k3=v3");


___NOTES___

Created on 20/04/2022, 13:40:31


