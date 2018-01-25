package com.boomegg.cocoslib.core;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

public class PluginManager {

	protected ConcurrentHashMap<String, IPlugin> pluginMap = new ConcurrentHashMap<String, IPlugin>();
	
	public void addPlugin(String id, IPlugin plugin) {
		if(!pluginMap.containsKey(id) && plugin != null) {
			plugin.setId(id);
			pluginMap.put(id, plugin);
		}
	}
	
	public IPlugin getPlugin(String id) {
		return pluginMap.containsKey(id) ? pluginMap.get(id) : null;
	}
	
	public List<IPlugin> findPluginByClass(Class<?> clz) {
		List<IPlugin> list = new ArrayList<IPlugin>();
		Iterator<String> it = pluginMap.keySet().iterator();
		while(it.hasNext()) {
			IPlugin plugin = pluginMap.get(it.next());
			if(clz.isInstance(plugin)) {
				list.add(plugin);
			}
		}
		return list;
	}
	
	public void initialize() {
		Iterator<String> it = pluginMap.keySet().iterator();
		while(it.hasNext()) {
			IPlugin plugin = pluginMap.get(it.next());
			plugin.initialize();
		}
	}
}
