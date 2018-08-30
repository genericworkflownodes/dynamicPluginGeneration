package @PLUGIN_DOMAIN@.@PLUGIN_NAME@;

import com.genericworkflownodes.knime.custom.config.IPluginConfiguration;
import com.genericworkflownodes.knime.dynamic.DynamicGenericNodeFactory;

public class GeneratedNodeFactory extends DynamicGenericNodeFactory {

    @Override
    protected IPluginConfiguration getPluginConfig() {
            return GeneratedNodeBundleActivator.getInstance().getPluginConfiguration();
    }
}
