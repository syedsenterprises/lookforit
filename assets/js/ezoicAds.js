(function() {
    const path = window.location.pathname;
    const targets = ['/articles/', '/tools/', '/web-tools/', '/ai-code/', '/ai-image/', '/ai-video/', '/ai-voice/', '/ai-writing/'];
    if (!targets.some(t => path.includes(t))) return;

    if (document.getElementById('ezoic-pub-ad-placeholder-110')) return;

    function insertAfter(newNode, referenceNode) {
        if (referenceNode && referenceNode.parentNode) {
            referenceNode.parentNode.insertBefore(newNode, referenceNode.nextSibling);
        }
    }

    function createPlaceholder(id) {
        const div = document.createElement('div');
        div.id = 'ezoic-pub-ad-placeholder-' + id;
        return div;
    }

    const h1 = document.querySelector('h1');
    if (h1) insertAfter(createPlaceholder(110), h1);

    const sections = document.querySelectorAll('section');
    if (sections.length > 0) {
        insertAfter(createPlaceholder(111), sections[0]);
        if (sections.length > 1) {
            insertAfter(createPlaceholder(112), sections[1]);
        } else {
             const main = document.querySelector('main') || document.body;
             main.appendChild(createPlaceholder(112));
        }
    }
    
    const footer = document.querySelector('footer');
    if (footer) {
        footer.parentNode.insertBefore(createPlaceholder(113), footer);
    } else {
        document.body.appendChild(createPlaceholder(113));
    }

    if (window.ezstandalone) {
        ezstandalone.cmd.push(function() {
            ezstandalone.showAds(110, 111, 112, 113);
        });
    }
})();
