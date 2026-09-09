{ config, pkgs, ... }:

let t = import ../../theme/tokens.nix;
in
{
  # eww widgets, ilyamiro-style: a minimised clock+weather PILL lives on the
  # desktop (or is summoned), and clicking it EXPANDS into a full dashboard
  # (big clock, sun-arc, calendar, weather with gauges). Collapse on click.
  # All in your Ember Deep palette (rust accent, teal secondary).
  programs.eww = {
    enable = true;
    configDir = ./eww;
  };

  xdg.configFile."eww/eww.yuck".text = ''
    ;; ---------- state ----------
    (defvar expanded false)

    ;; ---------- polls ----------
    (defpoll time      :interval "5s"  "date '+%H:%M'")
    (defpoll time_sec  :interval "1s"  "date '+%S'")
    (defpoll date_full :interval "60s" "date '+%A, %B %d'")
    (defpoll weekday   :interval "3600s" "date '+%A'")
    (defpoll cal_out   :interval "3600s" "cal --color=never")
    ;; weather via wttr.in: temp + condition + wind/humidity
    (defpoll w_temp    :interval "900s" "curl -sf 'wttr.in/Bath?format=%t' | tr -d '+' || echo '--'")
    (defpoll w_cond    :interval "900s" "curl -sf 'wttr.in/Bath?format=%C' || echo '--'")
    (defpoll w_wind    :interval "900s" "curl -sf 'wttr.in/Bath?format=%w' || echo '--'")
    (defpoll w_humid   :interval "900s" "curl -sf 'wttr.in/Bath?format=%h' || echo '--'")
    (defpoll w_icon    :interval "900s" "curl -sf 'wttr.in/Bath?format=%c' || echo ''")

    ;; ---------- MINIMISED PILL ----------
    (defwidget clock-pill []
      (eventbox :cursor "pointer"
        (button :class "pill" :onclick "eww update expanded=true && eww open dashboard"
          (box :orientation "h" :space-evenly false :spacing 12
            (box :orientation "v" :space-evenly false
              (label :class "pill-time" :text time)
              (label :class "pill-date" :text date_full))
            (box :class "pill-sep")
            (box :orientation "h" :space-evenly false :spacing 6
              (label :class "pill-wicon" :text w_icon)
              (label :class "pill-temp" :text "''${w_temp}°"))))))

    ;; ---------- EXPANDED DASHBOARD ----------
    (defwidget dash []
      (box :class "dash" :orientation "h" :space-evenly false :spacing 24
        ;; left: calendar
        (box :class "dash-cal" :orientation "v" :space-evenly false
          (label :class "cal-head" :text weekday)
          (label :class "cal-grid" :text cal_out))
        ;; centre: big clock
        (box :class "dash-clock" :orientation "v" :space-evenly false :valign "center"
          (box :orientation "h" :space-evenly false :valign "end"
            (label :class "big-time" :text time)
            (label :class "big-sec" :text ":''${time_sec}"))
          (label :class "big-date" :text date_full))
        ;; right: weather
        (box :class "dash-weather" :orientation "v" :space-evenly false :spacing 6
          (label :class "w-big" :text "''${w_temp}°")
          (label :class "w-cond" :text w_cond)
          (box :class "w-gauges" :orientation "h" :space-evenly true :spacing 14
            (gauge :icon "" :val w_wind  :lbl "WIND")
            (gauge :icon "" :val w_humid :lbl "HUMID")))))

    (defwidget gauge [icon val lbl]
      (box :class "gauge" :orientation "v" :space-evenly false :spacing 2
        (label :class "gauge-icon" :text icon)
        (label :class "gauge-val" :text val)
        (label :class "gauge-lbl" :text lbl)))

    ;; ---------- windows ----------
    (defwindow clock-widget
      :monitor 0
      :geometry (geometry :x "40px" :y "40px" :anchor "top left"
                          :width "260px" :height "70px")
      :stacking "bg" :exclusive false
      (clock-pill))

    (defwindow dashboard
      :monitor 0
      :geometry (geometry :x "0px" :y "0px" :anchor "center"
                          :width "900px" :height "340px")
      :stacking "overlay"
      (eventbox :onclick "eww update expanded=false && eww close dashboard"
        (dash)))
  '';

  xdg.configFile."eww/eww.scss".text = ''
    * { all: unset; font-family: "${t.font.mono}"; }

    /* ---- minimised pill ---- */
    .pill {
      background-color: rgba(22,28,43,0.85);
      border: 1px solid ${t.color.surface};
      border-radius: ${toString t.radius.lg}px;
      padding: 8px 16px;
    }
    .pill:hover { border-color: ${t.color.accent}; }
    .pill-time { font-size: 22px; font-weight: 600; color: ${t.color.fgBright}; }
    .pill-date { font-size: 11px; color: ${t.color.teal}; }
    .pill-sep  { background-color: ${t.color.surface}; min-width: 1px; margin: 4px 2px; }
    .pill-wicon{ font-size: 18px; color: ${t.color.teal}; }
    .pill-temp { font-size: 16px; color: ${t.color.fg}; }

    /* ---- expanded dashboard ---- */
    .dash {
      background-color: rgba(16,20,31,0.94);
      border: 1px solid ${t.color.surface};
      border-radius: ${toString t.radius.lg}px;
      padding: 28px 36px;
    }
    .cal-head { font-size: 15px; color: ${t.color.teal}; margin-bottom: 8px; }
    .cal-grid { font-size: 13px; color: ${t.color.fgDim}; }

    .big-time { font-size: 84px; font-weight: 700; color: ${t.color.fgBright}; }
    .big-sec  { font-size: 32px; color: ${t.color.accent}; margin-bottom: 12px; }
    .big-date { font-size: 16px; color: ${t.color.fgDim}; }

    .w-big  { font-size: 60px; font-weight: 700; color: ${t.color.fgBright}; }
    .w-cond { font-size: 15px; color: ${t.color.teal}; }
    .w-gauges { margin-top: 10px; }
    .gauge-icon { font-size: 18px; color: ${t.color.accent}; }
    .gauge-val  { font-size: 13px; color: ${t.color.fg}; }
    .gauge-lbl  { font-size: 10px; color: ${t.color.fgDim}; }
  '';
}
