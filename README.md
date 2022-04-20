# GTM Server-Side Variable Template for Filtering Out Query String Parameters
This Server Side Google Tag Manager Variable Template allows you to specify search query keys that you need whitelisted or blacklisted.

This is useful for filtering out data that you don't want passed on to, for example, Google Analytics or the Facebook Conversion API.

## Why a new template?
At the time of writing, the existing tempaltes had idiomatic flaws or features that are generally useful. In some cases the final URL was made lowercase and in others the hash fragment was ignored and removed.

This template works only on the query string parameters and keeps the rest of the source URL largely in tact.

## How it works
You simply
- choose a source for the URL
- specify whether you want to supply a white or black list of query parameters to filter with
- specify all the query parameters for your filter, each with a case sensitivity flag.

The tests are reasonably complete and you can see the basics of how it operates there.

### Choose a URL source
The default is to use the eventData.page_location however you can change this to any variable you choose.

### Choose a filter type
- A _whitelist_ will keep only the query parameters that you specify and remove all the rest from the final URL.
- A _blacklist_ will remove all the query parameters that you specify and keep the rest in the final URL.

### Specify your filter list
You need to add the Query PArameters for your filter. For each row in the table, give the
- _name_ of the query key
- specify whether you want a case sensitive match done or not (default is case insensitive)

A _case sensitive_ match will only match a query string parameter to your specified filter parameter if they both match with the same case. For example, if the Source URL is _https://example.com/?kEy=value_
- Filter Parameter _kEy_ will match
- Filter Parameter _key_ will not match

## Examples
### Use a Blacklist to remove _fbclid_ for GA4
With a Source URL as _https://example.com/?key=value&fbclid=1234#target_, we want to remove _fbclid_ before submitting event data to GA4.
- Choose a _blacklist_
- add _fbclid_ as a filter parameter with no case sensitive matching

Result will be _https://example.com/?key=value#target_

### Use a whitelist to remove PII data
With a Source URL as _https://example.com/?key=value&email=a@b.com&name=Bob_, we want to keep only key=value and remove the email and name parameters before submitting event data to GA4.
- Choose a _whitelist_
- add _key_ as a filter parameter

Result will be _https://example.com/?key=value_
