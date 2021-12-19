var FindProxyForURL = function(init, profiles) {
    return function(url, host) {
        "use strict";
        var result = init, scheme = url.substr(0, url.indexOf(":"));
        do {
            result = profiles[result];
            if (typeof result === "function") result = result(url, host, scheme);
        } while (typeof result !== "string" || result.charCodeAt(0) === 43);
        return result;
    };
}("+GBF-PROXY", {
    "+GBF-PROXY": function() {
        ;
function FindProxyForURL(url, host) {
    if (dnsDomainIs(host, ".granbluefantasy.jp")) {
        return "PROXY yourip:yourport";
    }
    return "DIRECT";
}

/* End of PAC */;
        return FindProxyForURL;
    }.call(this)
});
