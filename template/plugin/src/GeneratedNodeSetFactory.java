package @PLUGIN_DOMAIN@.@PLUGIN_NAME@;

import com.genericworkflownodes.knime.custom.config.IPluginConfiguration;
import com.genericworkflownodes.knime.dynamic.DynamicGenericNodeFactory;
import com.genericworkflownodes.knime.dynamic.DynamicGenericNodeSetFactory;

public class GeneratedNodeSetFactory extends DynamicGenericNodeSetFactory {

    public GeneratedNodeSetFactory() {
        super();
    }

    @Override
    public Class<? extends DynamicGenericNodeFactory> getNodeFactory() {
        return GeneratedNodeFactory.class;
    }

    @Override
    public String getCategoryPath() {
        return "/community/@PLUGIN_CATEGORY@";
    }

    @Override
    protected String getIdForTool(String relPath) {
        return "@PLUGIN_DOMAIN@." + relPath.replace('/', '.').replaceAll("[^0-9a-zA-Z]", "_");
    }

    @Override
    public IPluginConfiguration getPluginConfig() {
        return GeneratedNodeBundleActivator.getInstance().getPluginConfiguration();
    }

    // @Override
    // protected String getCategoryGroup() {
    //     return "SeqAn";
    // }
}
