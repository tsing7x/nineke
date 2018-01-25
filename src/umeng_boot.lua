-- 友盟需求整理:
-- 1. 从启动或前台开始, 每次进入后台的时间 < 30s, 统计;
-- 2. 统计游戏启动到大厅用时
-- 3. 统计关闭应用( 限定为进入后台 ) 在loading界面
-- 4. 统计关闭应用( 限定为进入后台 ) 在登录界面

-- 计算启动时间等操作 暂定这样实现, 如有更好意见稍后重构
-- David Feng, May 13, 2015
global_statistics_for_umeng = global_statistics_for_umeng or {

    Views = {
        login   = 'login',
        loading = 'loading',
        other   = 'other',
    },

    -- 统计的基准时间点, 用来统计/计算loading界面和登录界面关闭应用
    run_main_timestamp       = false,

    -- 启动后第一次进入大厅的时间 之后的进入大厅不再统计
    first_enter_hall_checked = false,

    -- 检查是否为第一次进入loading
    first_enter_loading_not_checked = true,

    -- 检查是否为第一次进入login
    first_enter_login_not_checked = true,

    -- 进入前台的时间, 每次进入前台都会更新此时间 用来统计10秒内退出
    enter_foreground_time    = false,
}

if not global_statistics_for_umeng.run_main_timestamp then
    global_statistics_for_umeng.run_main_timestamp = os.time()
end
