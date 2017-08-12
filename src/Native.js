'use strict';

function withRev(doc, rev) {
    if (rev.ctor === "Just") {
        doc._rev = rev._0
    }
}
