import zhCN from './zh-CN.json'
import enUS from './en-US.json'
import viVN from './vi-VN.json'


const _locales = {
  'zh-CN': zhCN,
  'en-US': enUS,
  'vi-VN': viVN,
}

// sort locales by key
export const locales = Object.fromEntries(
  Object.entries(_locales).sort(([keyA], [keyB]) => {
    return keyA.localeCompare(keyB)
  }),
) as typeof _locales
