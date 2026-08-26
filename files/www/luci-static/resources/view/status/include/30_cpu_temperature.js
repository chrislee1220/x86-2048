'use strict';
'require baseclass';
'require fs';

function formatTemp(raw) {
	var value = Number(raw);

	if (!isFinite(value))
		return null;

	if (value > 1000)
		value = value / 1000;

	return value.toFixed(value >= 100 ? 0 : 1) + ' \u00b0C';
}

return baseclass.extend({
	title: _('CPU Temperature'),

	load: function() {
		return fs.exec_direct('/bin/sh', [ '-c',
			'for zone in /sys/class/thermal/thermal_zone*; do ' +
				'[ -r "$zone/temp" ] || continue; ' +
				'name="$(cat "$zone/type" 2>/dev/null || basename "$zone")"; ' +
				'temp="$(cat "$zone/temp" 2>/dev/null || true)"; ' +
				'[ -n "$temp" ] && printf "%s=%s\\n" "$name" "$temp"; ' +
			'done'
		]).catch(function() {
			return '';
		});
	},

	render: function(data) {
		var rows = (data || '').trim().split(/\n/).map(function(line) {
			var idx = line.lastIndexOf('=');
			var label = idx > 0 ? line.slice(0, idx) : '';
			var temp = idx > 0 ? formatTemp(line.slice(idx + 1)) : null;

			if (!label || !temp)
				return null;

			return E('div', { 'class': 'tr' }, [
				E('div', { 'class': 'td left', 'width': '33%' }, [ label ]),
				E('div', { 'class': 'td left' }, [ temp ])
			]);
		}).filter(Boolean);

		if (!rows.length)
			rows.push(E('div', { 'class': 'tr placeholder' }, [
				E('div', { 'class': 'td' }, _('No temperature sensor data available'))
			]));

		return E('div', { 'class': 'table' }, rows);
	}
});
