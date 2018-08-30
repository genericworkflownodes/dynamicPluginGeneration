package @PLUGIN_DOMAIN@.@PLUGIN_NAME@;

import java.util.Collections;
import java.util.List;

import org.osgi.framework.BundleContext;

import com.genericworkflownodes.knime.custom.GenericActivator;
import com.genericworkflownodes.knime.custom.config.IPluginConfiguration;
import com.genericworkflownodes.knime.custom.config.impl.PluginConfiguration;
import com.genericworkflownodes.knime.toolfinderservice.ExternalTool;

public class GeneratedNodeBundleActivator extends GenericActivator {

	private static GeneratedNodeBundleActivator INSTANCE = null;
    private static IPluginConfiguration PLUGIN_CONFIG = null;

    public GeneratedNodeBundleActivator() {}

    @Override
    public void start(BundleContext context) throws Exception {
    	super.start(context);
    	initializePlugin();
    	INSTANCE = this;
    }

    public static GeneratedNodeBundleActivator getInstance() {
        return INSTANCE;
    }

    @Override
    public IPluginConfiguration getPluginConfiguration() {
        if (PLUGIN_CONFIG == null) {
            // construct the plugin config
            PLUGIN_CONFIG = new PluginConfiguration("@PLUGIN_ID@", "@PLUGIN_NAME@",
                GeneratedNodeBundleActivator.getInstance().getProperties(), getClass());
        }
        return PLUGIN_CONFIG;
    }

	@Override
	public List<ExternalTool> getTools() {
		// This method is not necessary anymore
		return Collections.emptyList();
	}
}
