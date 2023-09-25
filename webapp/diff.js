function line_text(text1) {
  var table = '';

  function make_row(x, text) {
    var row = '<tr>';
    row += '<td class="lineno">' + x + '</td>';
    row += '<td class="difftext"> ' + text + '</td>';
	row += '</tr>';
    table += row;
  }

  function loop(a1) {
    var x;

    for (x = 0; x < a1.length; x++) {
      make_row(x+1, a1[x]);
    }    
  }

  loop(text1.split('\n'));
  return '<table class="diff_text">' + table + '</table>';
}

function diff_text(text1, text2) {
  var table = '';

  function make_row(x, y, type, text) {
    if (type == ' ') return;
    var row = '<tr';
    if (type == '+') row += ' class="add"';
    else if (type == '-') row += ' class="del"';
    row += '>';

    row += '<td class="lineno">' + y;
    row += '<td class="lineno">' + x;
    row += '<td class="difftext">' + type + ' ' + text;

    table += row;
  }

  function get_diff(matrix, a1, a2, x, y) {
    if (x > 0 && y > 0 && a1[y-1] === a2[x-1]) {
      get_diff(matrix, a1, a2, x-1, y-1);
      make_row(x, y, ' ', a1[y-1]);
    }
    else {
      if (x > 0 && (y === 0 || matrix[y][x-1] >= matrix[y-1][x])) {
        get_diff(matrix, a1, a2, x-1, y);
        make_row(x, '', '+', a2[x-1]);
      }
      else if (y > 0 && (x === 0 || matrix[y][x-1] < matrix[y-1][x])) {
        get_diff(matrix, a1, a2, x, y-1);
        make_row('', y, '-', a1[y-1]);
      }
      else {
        return;
      }
    }
  }

  function diff(a1, a2) {
    var matrix = new Array(a1.length + 1);
    var x, y;

    for (y = 0; y < matrix.length; y++) {
      matrix[y] = new Array(a2.length + 1);

      for (x = 0; x < matrix[y].length; x++) {
        matrix[y][x] = 0;
      }
    }
    
    for (y = 1; y < matrix.length; y++) {
      for (x = 1; x < matrix[y].length; x++) {
        if (a1[y-1] === a2[x-1]) {
          matrix[y][x] = 1 + matrix[y-1][x-1];
        }
        else {
          matrix[y][x] = Math.max(matrix[y-1][x], matrix[y][x-1]);
        }
      }
    }

    get_diff(matrix, a1, a2, x-1, y-1);
  }

  diff(text1.split('\n'), text2.split('\n'));
  return '<table class="diff_text">' + table + '</table>';
}