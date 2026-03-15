/*
	Editorial by HTML5 UP
	html5up.net | @ajlkn
	Free for personal and commercial use under the CCA 3.0 license (html5up.net/license)
*/

(function($) {

	var	$window = $(window),
		$head = $('head'),
		$body = $('body');

	// Normalize branding text across pages.
	(function normalizeHeaderBranding() {
		var $header = $('#header');
		if ($header.length === 0)
			return;

		var $logo = $header.find('a.logo').first();
		if ($logo.length === 0)
			return;

		$logo.html('<strong>Lookforit</strong>');
		$header.find('.logo-by, .logo-author').remove();
	})();

	function isMobileView() {
		return window.matchMedia('(max-width: 736px)').matches;
	}

	// Keep header search mobile-only.
	function syncHeaderSearchMobile() {
		var $header = $('#header');
		if ($header.length === 0)
			return;

		var $existing = $header.find('.header-search');

		if (isMobileView()) {
			if ($existing.length > 0)
				return;

			var searchHtml = ''
				+ '<div class="header-search">'
				+ '<form method="get" action="/tools/">'
				+ '<input type="text" name="query" id="header-query" placeholder="Search tools..." aria-label="Search tools" />'
				+ '</form>'
				+ '</div>';

			var $icons = $header.children('ul.icons').first();
			if ($icons.length > 0)
				$icons.before($(searchHtml));
			else
				$header.append($(searchHtml));
			return;
		}

		$existing.remove();
	}

	// Social icons: ensure a consistent icon row exists in every page header.
	(function ensureHeaderIcons() {
		var $header = $('#header');
		if ($header.length === 0)
			return;

		if ($header.children('ul.icons').length > 0)
			return;

		var iconsHtml = ''
			+ '<ul class="icons">'
			+ '<li><a href="https://x.com/syedShahid1433" class="icon brands fa-twitter" target="_blank" rel="noopener noreferrer"><span class="label">Twitter</span></a></li>'
			+ '<li><a href="https://www.facebook.com/syed.shahed.273196" class="icon brands fa-facebook-f" target="_blank" rel="noopener noreferrer"><span class="label">Facebook</span></a></li>'
			+ '<li><a href="https://www.youtube.com/@Ampersent" class="icon brands fa-youtube" target="_blank" rel="noopener noreferrer"><span class="label">YouTube</span></a></li>'
			+ '<li><a href="https://www.instagram.com/shah.voidheart/" class="icon brands fa-instagram" target="_blank" rel="noopener noreferrer"><span class="label">Instagram</span></a></li>'
			+ '<li><a href="https://medium.com/@syedsinterprises" class="icon brands fa-medium-m" target="_blank" rel="noopener noreferrer"><span class="label">Medium</span></a></li>'
			+ '<li><a href="https://chat.whatsapp.com/J6EsOm6PFqgBZm2nkNy3w3" class="icon brands fa-whatsapp" target="_blank" rel="noopener noreferrer"><span class="label">Community</span></a></li>'
			+ '</ul>';

		$header.append($(iconsHtml));
	})();

	// Group sidebar sections only on mobile drawer view and remove grouping on desktop.
	function syncSidebarMobileGroups() {
		var $inner = $('#sidebar > .inner');
		if ($inner.length === 0)
			return;

		if (!window.matchMedia('(max-width: 1280px)').matches) {
			$inner.children('.sidebar-menu-group').each(function() {
				var $group = $(this);
				$group.children().appendTo($inner);
				$group.remove();
			});
			return;
		}

		if ($inner.children('.sidebar-menu-group').length > 0)
			return;

		var $children = $inner.children();
		var $menu = $inner.children('#menu').first();
		var $categorySection = $inner.children('section').filter(function() {
			return $(this).find('h2').first().text().trim().toLowerCase() === 'categories';
		}).first();
		var $contactSection = $inner.children('section').filter(function() {
			return $(this).find('h2').first().text().trim().toLowerCase() === 'get in touch';
		}).first();
		var $footer = $inner.children('#footer').first();

		if ($menu.length > 0 && $categorySection.length > 0) {
			var headerStart = $children.index($menu);
			var headerEnd = $children.index($categorySection);
			if (headerStart >= 0 && headerEnd >= headerStart) {
				var $headerWrap = $('<div class="sidebar-menu-group sidebar-header-menu" />');
				$menu.before($headerWrap);
				$children.slice(headerStart, headerEnd + 1).appendTo($headerWrap);
			}
		}

		if ($contactSection.length > 0 && $footer.length > 0) {
			$children = $inner.children();
			var footerStart = $children.index($contactSection);
			var footerEnd = $children.index($footer);
			if (footerStart >= 0 && footerEnd >= footerStart) {
				var $footerWrap = $('<div class="sidebar-menu-group sidebar-footer-menu" />');
				$contactSection.before($footerWrap);
				$children.slice(footerStart, footerEnd + 1).appendTo($footerWrap);
			}
		}
	}

	syncHeaderSearchMobile();
	syncSidebarMobileGroups();

	// Breakpoints.
		breakpoints({
			xlarge:   [ '1281px',  '1680px' ],
			large:    [ '981px',   '1280px' ],
			medium:   [ '737px',   '980px'  ],
			small:    [ '481px',   '736px'  ],
			xsmall:   [ '361px',   '480px'  ],
			xxsmall:  [ null,      '360px'  ],
			'xlarge-to-max':    '(min-width: 1681px)',
			'small-to-xlarge':  '(min-width: 481px) and (max-width: 1680px)'
		});

	// Stops animations/transitions until the page has ...

		// ... loaded.
			$window.on('load', function() {
				window.setTimeout(function() {
					$body.removeClass('is-preload');
				}, 100);
			});

		// ... stopped resizing.
			var resizeTimeout;

			$window.on('resize', function() {

				// Mark as resizing.
					$body.addClass('is-resizing');

				// Unmark after delay.
					clearTimeout(resizeTimeout);

					resizeTimeout = setTimeout(function() {
						$body.removeClass('is-resizing');
					}, 100);

					syncHeaderSearchMobile();
					syncSidebarMobileGroups();

			});

	// Fixes.

		// Object fit images.
			if (!browser.canUse('object-fit')
			||	browser.name == 'safari')
				$('.image.object').each(function() {

					var $this = $(this),
						$img = $this.children('img');

					// Hide original image.
						$img.css('opacity', '0');

					// Set background.
						$this
							.css('background-image', 'url("' + $img.attr('src') + '")')
							.css('background-size', $img.css('object-fit') ? $img.css('object-fit') : 'cover')
							.css('background-position', $img.css('object-position') ? $img.css('object-position') : 'center');

				});

	// Sidebar.
		var $sidebar = $('#sidebar'),
			$sidebar_inner = $sidebar.children('.inner');

		// Inactive by default on <= large.
			breakpoints.on('<=large', function() {
				$sidebar.addClass('inactive');
			});

			breakpoints.on('>large', function() {
				$sidebar.removeClass('inactive');
			});

		// Hack: Workaround for Chrome/Android scrollbar position bug.
			if (browser.os == 'android'
			&&	browser.name == 'chrome')
				$('<style>#sidebar .inner::-webkit-scrollbar { display: none; }</style>')
					.appendTo($head);

		// Toggle.
			$('<a href="#sidebar" class="toggle">Toggle</a>')
				.appendTo($sidebar)
				.on('click', function(event) {

					// Prevent default.
						event.preventDefault();
						event.stopPropagation();

					// Toggle.
						$sidebar.toggleClass('inactive');

				});

		// Events.

			// Link clicks.
				$sidebar.on('click', 'a', function(event) {

					// >large? Bail.
						if (breakpoints.active('>large'))
							return;

					// Vars.
						var $a = $(this),
							href = $a.attr('href'),
							target = $a.attr('target');

					// Prevent default.
						event.preventDefault();
						event.stopPropagation();

					// Check URL.
						if (!href || href == '#' || href == '')
							return;

					// Hide sidebar.
						$sidebar.addClass('inactive');

					// Redirect to href.
						setTimeout(function() {

							if (target == '_blank')
								window.open(href);
							else
								window.location.href = href;

						}, 500);

				});

			// Prevent certain events inside the panel from bubbling.
				$sidebar.on('click touchend touchstart touchmove', function(event) {

					// >large? Bail.
						if (breakpoints.active('>large'))
							return;

					// Prevent propagation.
						event.stopPropagation();

				});

			// Hide panel on body click/tap.
				$body.on('click touchend', function(event) {

					// >large? Bail.
						if (breakpoints.active('>large'))
							return;

					// Deactivate.
						$sidebar.addClass('inactive');

				});

		// Scroll lock.
		// Note: If you do anything to change the height of the sidebar's content, be sure to
		// trigger 'resize.sidebar-lock' on $window so stuff doesn't get out of sync.

			$window.on('load.sidebar-lock', function() {

				var sh, wh, st;

				// Reset scroll position to 0 if it's 1.
					if ($window.scrollTop() == 1)
						$window.scrollTop(0);

				$window
					.on('scroll.sidebar-lock', function() {

						var x, y;

						// <=large? Bail.
							if (breakpoints.active('<=large')) {

								$sidebar_inner
									.data('locked', 0)
									.css('position', '')
									.css('top', '');

								return;

							}

						// Calculate positions.
							x = Math.max(sh - wh, 0);
							y = Math.max(0, $window.scrollTop() - x);

						// Lock/unlock.
							if ($sidebar_inner.data('locked') == 1) {

								if (y <= 0)
									$sidebar_inner
										.data('locked', 0)
										.css('position', '')
										.css('top', '');
								else
									$sidebar_inner
										.css('top', -1 * x);

							}
							else {

								if (y > 0)
									$sidebar_inner
										.data('locked', 1)
										.css('position', 'fixed')
										.css('top', -1 * x);

							}

					})
					.on('resize.sidebar-lock', function() {

						// Calculate heights.
							wh = $window.height();
							sh = $sidebar_inner.outerHeight() + 30;

						// Trigger scroll.
							$window.trigger('scroll.sidebar-lock');

					})
					.trigger('resize.sidebar-lock');

				});

	// Menu.
		var $menu = $('#menu'),
			$menu_openers = $menu.children('ul').find('.opener');

		// Openers.
			$menu_openers.each(function() {

				var $this = $(this);

				$this.on('click', function(event) {

					// Prevent default.
						event.preventDefault();

					// Toggle.
						$menu_openers.not($this).removeClass('active');
						$this.toggleClass('active');

					// Trigger resize (sidebar lock).
						$window.triggerHandler('resize.sidebar-lock');

				});

			});

	// Comments, reviews, and rating widget (articles/tools detail pages).
		(function() {
			var path = (window.location.pathname || '').toLowerCase();

			var isArticleDetail =
				path.indexOf('/articles/') !== -1 &&
				path.indexOf('/articles/index.html') === -1;

			var isToolDetail =
				path.indexOf('/tools/') !== -1 &&
				path.indexOf('/tools/index.html') === -1 &&
				path.indexOf('/tools/category/') === -1;

			if (!isArticleDetail && !isToolDetail)
				return;

			var $mainInner = $('#main .inner').first();
			if ($mainInner.length === 0 || $('#feedback-hub').length > 0)
				return;

			var pageKey = (window.location.pathname || 'unknown-page')
				.toLowerCase()
				.replace(/[^a-z0-9]+/g, '-');

			var storageKeys = {
				reviews: 'lookforit-feedback-reviews:' + pageKey,
				comments: 'lookforit-feedback-comments:' + pageKey
			};

			var $targetSection = $mainInner.children('section').last();
			if ($targetSection.length === 0)
				$targetSection = $mainInner;

			$targetSection.append(
				'<section id="feedback-hub" class="feedback-hub">'
				+ '<header class="major"><h2>Comments, Reviews and Ratings</h2></header>'
				+ '<div class="feedback-grid">'
				+ '<div class="feedback-card">'
				+ '<h3>Rate and Review</h3>'
				+ '<p class="feedback-meta">Average rating: <strong id="feedback-average">0.0</strong> / 5 (<span id="feedback-review-count">0</span> reviews)</p>'
				+ '<form id="feedback-review-form" class="feedback-form" novalidate>'
				+ '<div class="field"><label for="reviewer-name">Name</label><input type="text" id="reviewer-name" maxlength="60" placeholder="Your name" /></div>'
				+ '<div class="field"><label>Your rating</label>'
				+ '<div class="rating-stars" id="rating-stars">'
				+ '<button type="button" data-value="1" aria-label="Rate 1 star">★</button>'
				+ '<button type="button" data-value="2" aria-label="Rate 2 stars">★</button>'
				+ '<button type="button" data-value="3" aria-label="Rate 3 stars">★</button>'
				+ '<button type="button" data-value="4" aria-label="Rate 4 stars">★</button>'
				+ '<button type="button" data-value="5" aria-label="Rate 5 stars">★</button>'
				+ '</div>'
				+ '<input type="hidden" id="review-rating" value="0" />'
				+ '</div>'
				+ '<div class="field"><label for="review-text">Review</label><textarea id="review-text" rows="4" maxlength="800" placeholder="Share your experience..."></textarea></div>'
				+ '<ul class="actions"><li><button type="submit" class="button primary">Submit Review</button></li></ul>'
				+ '</form>'
				+ '<div id="feedback-review-list" class="feedback-list" aria-live="polite"></div>'
				+ '</div>'
				+ '<div class="feedback-card">'
				+ '<h3>Comments</h3>'
				+ '<form id="feedback-comment-form" class="feedback-form" novalidate>'
				+ '<div class="field"><label for="commenter-name">Name</label><input type="text" id="commenter-name" maxlength="60" placeholder="Your name" /></div>'
				+ '<div class="field"><label for="comment-text">Comment</label><textarea id="comment-text" rows="4" maxlength="800" placeholder="Write a comment..."></textarea></div>'
				+ '<ul class="actions"><li><button type="submit" class="button">Post Comment</button></li></ul>'
				+ '</form>'
				+ '<div id="feedback-comment-list" class="feedback-list" aria-live="polite"></div>'
				+ '<p class="feedback-note">Note: feedback is stored in your browser on this device.</p>'
				+ '</div>'
				+ '</div>'
				+ '</section>'
			);

			function escapeHtml(value) {
				return String(value)
					.replace(/&/g, '&amp;')
					.replace(/</g, '&lt;')
					.replace(/>/g, '&gt;')
					.replace(/\"/g, '&quot;')
					.replace(/'/g, '&#39;');
			}

			function readStore(key) {
				try {
					var parsed = JSON.parse(localStorage.getItem(key) || '[]');
					return Array.isArray(parsed) ? parsed : [];
				}
				catch (e) {
					return [];
				}
			}

			function writeStore(key, value) {
				localStorage.setItem(key, JSON.stringify(value));
			}

			function formatDate(isoDate) {
				var d = new Date(isoDate);
				if (isNaN(d.getTime()))
					return 'Recently';

				return d.toLocaleDateString(undefined, {
					year: 'numeric',
					month: 'short',
					day: 'numeric'
				});
			}

			function syncStars(ratingValue) {
				$('#rating-stars button').each(function() {
					var v = parseInt($(this).attr('data-value'), 10) || 0;
					$(this).toggleClass('active', v <= ratingValue);
				});
			}

			function renderReviews() {
				var reviews = readStore(storageKeys.reviews);
				var $list = $('#feedback-review-list');

				if (reviews.length === 0) {
					$('#feedback-average').text('0.0');
					$('#feedback-review-count').text('0');
					$list.html('<p class="feedback-empty">No reviews yet. Be the first to rate this page.</p>');
					return;
				}

				var total = 0;
				for (var i = 0; i < reviews.length; i++)
					total += (parseInt(reviews[i].rating, 10) || 0);

				var avg = (total / reviews.length).toFixed(1);
				$('#feedback-average').text(avg);
				$('#feedback-review-count').text(String(reviews.length));

				var html = '';
				for (var j = 0; j < reviews.length; j++) {
					var review = reviews[j];
					var rating = Math.max(1, Math.min(5, parseInt(review.rating, 10) || 1));
					html += '<article class="feedback-item">'
						+ '<div class="feedback-item-head">'
						+ '<strong>' + escapeHtml(review.name) + '</strong>'
						+ '<span class="feedback-date">' + formatDate(review.createdAt) + '</span>'
						+ '</div>'
						+ '<div class="feedback-stars-readonly">' + '★'.repeat(rating) + '<span>' + '★'.repeat(5 - rating) + '</span></div>'
						+ '<p>' + escapeHtml(review.text) + '</p>'
						+ '</article>';
				}

				$list.html(html);
			}

			function renderComments() {
				var comments = readStore(storageKeys.comments);
				var $list = $('#feedback-comment-list');

				if (comments.length === 0) {
					$list.html('<p class="feedback-empty">No comments yet. Start the discussion.</p>');
					return;
				}

				var html = '';
				for (var i = 0; i < comments.length; i++) {
					var comment = comments[i];
					html += '<article class="feedback-item">'
						+ '<div class="feedback-item-head">'
						+ '<strong>' + escapeHtml(comment.name) + '</strong>'
						+ '<span class="feedback-date">' + formatDate(comment.createdAt) + '</span>'
						+ '</div>'
						+ '<p>' + escapeHtml(comment.text) + '</p>'
						+ '</article>';
				}

				$list.html(html);
			}

			$('#rating-stars').on('click', 'button', function() {
				var rating = parseInt($(this).attr('data-value'), 10) || 0;
				$('#review-rating').val(String(rating));
				syncStars(rating);
			});

			$('#feedback-review-form').on('submit', function(event) {
				event.preventDefault();

				var name = ($('#reviewer-name').val() || '').trim() || 'Anonymous';
				var text = ($('#review-text').val() || '').trim();
				var rating = parseInt($('#review-rating').val(), 10) || 0;

				if (rating < 1 || rating > 5) {
					window.alert('Please select a rating from 1 to 5 stars.');
					return;
				}

				if (!text) {
					window.alert('Please write a short review.');
					return;
				}

				var reviews = readStore(storageKeys.reviews);
				reviews.unshift({
					name: name,
					text: text,
					rating: rating,
					createdAt: new Date().toISOString()
				});

				writeStore(storageKeys.reviews, reviews.slice(0, 50));
				$('#reviewer-name').val('');
				$('#review-text').val('');
				$('#review-rating').val('0');
				syncStars(0);
				renderReviews();
			});

			$('#feedback-comment-form').on('submit', function(event) {
				event.preventDefault();

				var name = ($('#commenter-name').val() || '').trim() || 'Anonymous';
				var text = ($('#comment-text').val() || '').trim();

				if (!text) {
					window.alert('Please write a comment before posting.');
					return;
				}

				var comments = readStore(storageKeys.comments);
				comments.unshift({
					name: name,
					text: text,
					createdAt: new Date().toISOString()
				});

				writeStore(storageKeys.comments, comments.slice(0, 100));
				$('#commenter-name').val('');
				$('#comment-text').val('');
				renderComments();
			});

			renderReviews();
			renderComments();
		})();

	// Internal link click tracking for article recommendation widgets.
		(function() {
			var TRACK_STORE_KEY = 'lookforit-internal-link-clicks:v1';
			var TRACK_STORE_LIMIT = 250;

			function readStore() {
				try {
					var parsed = JSON.parse(localStorage.getItem(TRACK_STORE_KEY) || '[]');
					return Array.isArray(parsed) ? parsed : [];
				}
				catch (e) {
					return [];
				}
			}

			function writeStore(entry) {
				var rows = readStore();
				rows.unshift(entry);
				if (rows.length > TRACK_STORE_LIMIT)
					rows = rows.slice(0, TRACK_STORE_LIMIT);

				try {
					localStorage.setItem(TRACK_STORE_KEY, JSON.stringify(rows));
				}
				catch (e) {
					// Ignore quota/private-mode write failures.
				}
			}

			function clearStore() {
				try {
					localStorage.removeItem(TRACK_STORE_KEY);
				}
				catch (e) {
					// Ignore private-mode failures.
				}
			}

			function topLinks(limit) {
				var rows = readStore();
				var index = {};

				for (var i = 0; i < rows.length; i++) {
					var row = rows[i] || {};
					var href = String(row.link_href || '').trim();
					if (!href)
						continue;

					var key = String(row.widget_type || 'unknown') + '|' + href + '|' + String(row.link_text || '').trim();
					if (!index[key]) {
						index[key] = {
							widget_type: row.widget_type || 'unknown',
							link_href: href,
							link_text: String(row.link_text || '').trim(),
							count: 0,
							last_clicked_at: row.timestamp || null
						};
					}

					index[key].count += 1;
					if (!index[key].last_clicked_at && row.timestamp)
						index[key].last_clicked_at = row.timestamp;
				}

				var list = Object.keys(index).map(function(k) {
					return index[k];
				});

				list.sort(function(a, b) {
					if (b.count !== a.count)
						return b.count - a.count;

					return String(a.link_text || '').localeCompare(String(b.link_text || ''));
				});

				var max = typeof limit === 'number' ? Math.max(1, limit) : 10;
				return list.slice(0, max);
			}

			function toText(value) {
				return String(value || '').replace(/\s+/g, ' ').trim();
			}

			function sendToAnalytics(payload) {
				if (typeof window.gtag === 'function') {
					window.gtag('event', 'internal_link_click', payload);
				}

				if (Array.isArray(window.dataLayer)) {
					window.dataLayer.push({
						event: 'internal_link_click',
						internalLinkClick: payload
					});
				}
			}

			$body.on('click', '.related-guides-inline a, .next-recommended a', function() {
				var $link = $(this);
				var href = $link.attr('href') || '';
				if (!href || href.charAt(0) === '#')
					return;

				var widgetType = $link.closest('.next-recommended').length > 0
					? 'next_recommended'
					: 'related_guides';

				var payload = {
					widget_type: widgetType,
					link_text: toText($link.text()),
					link_href: href,
					source_path: window.location.pathname || '/',
					timestamp: new Date().toISOString()
				};

				writeStore(payload);
				sendToAnalytics(payload);

				if (typeof window.CustomEvent === 'function') {
					window.dispatchEvent(new CustomEvent('lookforit:internal-link-click', {
						detail: payload
					}));
				}
			});

			window.LookforitInternalLinkClicks = {
				getEvents: function() {
					return readStore();
				},
				clearEvents: function() {
					clearStore();
				},
				getTopLinks: function(limit) {
					return topLinks(limit);
				}
			};
		})();

	// Back to Top button (global).
		(function() {
			var $btn = $('<button id="back-to-top" type="button" aria-label="Back to top" title="Click here to back to top">Back to top</button>');
			$body.append($btn);

			$window.on('scroll.backToTop', function() {
				if ($window.scrollTop() > 400)
					$btn.addClass('visible');
				else
					$btn.removeClass('visible');
			});

			$btn.on('click', function() {
				$('html, body').animate({ scrollTop: 0 }, 350);
			});

			$window.trigger('scroll.backToTop');
		})();

})(jQuery);