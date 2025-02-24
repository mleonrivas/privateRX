function filterRow(r, min_profit, max_dd, show_stopped_tests) {
    min_profit = parseFloat(min_profit);
    max_dd = parseFloat(max_dd);
    if (show_stopped_tests == false && r.expected_benefit == "N/A") {
        return false;
    }
    return parseFloat(r.avg_year_profit_percent) >= min_profit && parseFloat(r.dd_percent) <= max_dd;
}

function unpack(rows, key, min_profit, max_dd, show_stopped_tests) {
    rows = rows.filter(function(r,i) {
        return filterRow(r, min_profit, max_dd, show_stopped_tests);
    });
    return rows.map(function(row) { return row[key]; });
}

function unpackCustomData(rows, min_profit, max_dd, show_stopped_tests) {
    rows = rows.filter(function(r,i) {
        return filterRow(r, min_profit, max_dd, show_stopped_tests);
    });
    return rows.map(function(row) {
        var result = [];
        result.push(row['test_num']);
        result.push(row['initial_deposit']);
        result.push(row['net_benefits']);
        result.push(row['final_balance']);
        result.push(row['total_profit_percent']);
        result.push(row['avg_year_profit_percent']);
        result.push(row['dd_percent']);
        return result; 
    });
}

function create_plot(rows, min_profit, max_dd, show_stopped_tests) {
    var ahv = 7;
    if (min_profit >= 15 && max_dd <=50) {
        ahv = 3;
    }
    var mydata=unpackCustomData(rows, min_profit, max_dd, show_stopped_tests);
    var x_ts_hs = unpack(rows, 'ts_history_size', min_profit, max_dd, show_stopped_tests);
    var y_ts_di = unpack(rows, 'ts_distances_increase', min_profit, max_dd, show_stopped_tests);
    var z_ts_ppp = unpack(rows, 'ts_price_point_percentage', min_profit, max_dd, show_stopped_tests);
    var data = [{
        x: x_ts_hs,
        y: y_ts_di,
        z: z_ts_ppp,
        mode: 'markers',
        type: 'scatter3d',
        marker: {
          color: 'rgb(23, 190, 207)',
          size: 3,
          symbol: 'circle'
        },
        hovertemplate: 'ID: %{customdata[0]}<br>TS_STAT_HistorySize: %{x}<br>TS_W_DistancesIncreasePercent: %{y}<br>TS_PricePointPercentage: %{z}<br>Initial Balance: %{customdata[1]}<br>Net Profit:%{customdata[2]}<br>Final Balance: %{customdata[3]}<br>Avg Yearly profit: %{customdata[5]}<br>Max Relative DD: %{customdata[6]}<extra></extra>',
        customdata: mydata,
    },{
        alphahull: ahv,
        opacity: 0.1,
        type: 'mesh3d',
        x: x_ts_hs,
        y: y_ts_di,
        z: z_ts_ppp,
        hovertemplate: 'ID: %{customdata[0]}<br>TS_STAT_HistorySize: %{x}<br>TS_W_DistancesIncreasePercent: %{y}<br>TS_PricePointPercentage: %{z}<br>Initial Balance: %{customdata[1]}<br>Net Profit:%{customdata[2]}<br>Final Balance: %{customdata[3]}<br>Avg Yearly profit: %{customdata[5]}<br>Max Relative DD: %{customdata[6]}<extra></extra>',
        customdata: mydata,
    }];

    var layout = {
        autosize: true,
        height: 980,
        width: 980,
        scene: {
            aspectratio: {
                x: 1,
                y: 1,
                z: 1
            },
            camera: {
                center: {
                    x: 0,
                    y: 0,
                    z: 0
                },
                eye: {
                    x: 1.25,
                    y: 1.25,
                    z: 1.25
                },
                up: {
                    x: 0,
                    y: 0,
                    z: 1
                }
            },
            xaxis: {
                type: 'linear',
                zeroline: true,
                title: "TS_STAT_HistorySize",
                range: [20, 100]
            },
            yaxis: {
                type: 'linear',
                zeroline: true,
                title: "TS_W_DistancesIncreasePercent",
                range: [0.1, 0.5]
            },
            zaxis: {
                type: 'linear',
                zeroline: true,
                title: "TS_PricePointPercentage",
                range: [0.1, 1.0]
            }
        },
        title: {
            text: 'RecoveryX Tests Results 3D Plot'
        }
    };

    Plotly.newPlot('myDiv', data, layout, {displayModeBar: true});
    return x_ts_hs.length;
}
