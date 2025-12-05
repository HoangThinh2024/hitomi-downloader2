use serde::{Deserialize, Serialize};
use specta::Type;

/// System information for monitoring and optimization
#[derive(Debug, Clone, Serialize, Deserialize, Type)]
#[serde(rename_all = "camelCase")]
pub struct SystemInfo {
    pub cpu_count: usize,
    pub os: String,
    pub os_version: String,
    pub arch: String,
    pub total_memory: u64,
    pub available_memory: u64,
}

impl SystemInfo {
    /// Get current system information
    /// This is useful for adaptive performance tuning on Linux
    pub fn get() -> Self {
        let cpu_count = std::thread::available_parallelism()
            .map(|n| n.get())
            .unwrap_or(1);

        // Get OS information
        let os = std::env::consts::OS.to_string();
        let os_version = get_os_version();
        let arch = std::env::consts::ARCH.to_string();

        // Get memory information (simplified, returns 0 if not available)
        let (total_memory, available_memory) = get_memory_info();

        SystemInfo {
            cpu_count,
            os,
            os_version,
            arch,
            total_memory,
            available_memory,
        }
    }
}

/// Get OS version string
fn get_os_version() -> String {
    #[cfg(target_os = "linux")]
    {
        // Try to read /etc/os-release for Linux distribution info
        if let Ok(content) = std::fs::read_to_string("/etc/os-release") {
            for line in content.lines() {
                if line.starts_with("PRETTY_NAME=") {
                    return line
                        .trim_start_matches("PRETTY_NAME=")
                        .trim_matches('"')
                        .to_string();
                }
            }
        }
        "Linux".to_string()
    }

    #[cfg(not(target_os = "linux"))]
    {
        "Unknown".to_string()
    }
}

/// Get memory information (total and available in bytes)
/// Returns (total, available) tuple
fn get_memory_info() -> (u64, u64) {
    #[cfg(target_os = "linux")]
    {
        // Parse /proc/meminfo for memory statistics
        if let Ok(content) = std::fs::read_to_string("/proc/meminfo") {
            let mut total = 0u64;
            let mut available = 0u64;

            for line in content.lines() {
                if line.starts_with("MemTotal:") {
                    if let Some(value) = parse_meminfo_line(line) {
                        total = value * 1024; // Convert KB to bytes
                    }
                } else if line.starts_with("MemAvailable:") {
                    if let Some(value) = parse_meminfo_line(line) {
                        available = value * 1024; // Convert KB to bytes
                    }
                }
            }

            return (total, available);
        }
    }

    (0, 0)
}

/// Parse a line from /proc/meminfo
/// Format: "MemTotal:       16384000 kB"
#[cfg(target_os = "linux")]
fn parse_meminfo_line(line: &str) -> Option<u64> {
    line.split_whitespace()
        .nth(1)
        .and_then(|s| s.parse::<u64>().ok())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_system_info() {
        let info = SystemInfo::get();
        assert!(info.cpu_count > 0);
        assert!(!info.os.is_empty());
        println!("System Info: {:?}", info);
    }

    #[cfg(target_os = "linux")]
    #[test]
    fn test_os_version() {
        let version = get_os_version();
        assert!(!version.is_empty());
        println!("OS Version: {}", version);
    }

    #[cfg(target_os = "linux")]
    #[test]
    fn test_memory_info() {
        let (total, available) = get_memory_info();
        println!("Memory: {} GB total, {} GB available", 
                 total / 1024 / 1024 / 1024,
                 available / 1024 / 1024 / 1024);
    }
}
